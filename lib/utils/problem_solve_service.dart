import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/problem_solving_page.dart';
import 'package:flutter/material.dart';

class ProblemSolveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 문제 상태 확인
  Future<Map<String, dynamic>> getProblemState({
    required String userId,
    required String problemId,
  }) async {
    final docRef =
        _firestore.collection('userProblemData').doc('${userId}_${problemId}');

    final doc = await docRef.get();
    return doc.data() ?? {};
  }

  Future<void> _saveDrawingData(
    String attemptId,
    List<List<DrawingPoint>> problemStrokes,
    List<List<DrawingPoint>> solutionStrokes,
  ) async {
    var batch = _firestore.batch();

    // Problem Strokes 저장
    for (int i = 0; i < problemStrokes.length; i++) {
      final stroke = problemStrokes[i];
      final firstPoint = stroke.first;

      final strokeDoc = _firestore
          .collection('drawingData')
          .doc(attemptId)
          .collection('problemStrokes')
          .doc(i.toString());

      batch.set(strokeDoc, {
        'color': firstPoint.color.value,
        'strokeWidth': firstPoint.strokeWidth,
        'coordinates': stroke
            .map((point) => {
                  'x': point.offset.dx,
                  'y': point.offset.dy,
                })
            .toList(),
        'index': i,
      });

      if (i % 500 == 499) {
        await batch.commit();
        batch = _firestore.batch();
      }
    }

    // Solution Strokes 저장
    for (int i = 0; i < solutionStrokes.length; i++) {
      final stroke = solutionStrokes[i];
      final firstPoint = stroke.first;

      final strokeDoc = _firestore
          .collection('drawingData')
          .doc(attemptId)
          .collection('solutionStrokes')
          .doc(i.toString());

      batch.set(strokeDoc, {
        'color': firstPoint.color.value,
        'strokeWidth': firstPoint.strokeWidth,
        'coordinates': stroke
            .map((point) => {
                  'x': point.offset.dx,
                  'y': point.offset.dy,
                })
            .toList(),
        'index': i,
      });

      if (i % 500 == 499) {
        await batch.commit();
        batch = _firestore.batch();
      }
    }

    await batch.commit();
  }

  // '정답 제출' 클릭 시 호출
  Future<String?> saveAttempt({
    required String userId,
    required String problemId,
    required String submittedAnswer,
    required bool isCorrect,
    required int timeSpent,
    required List<List<DrawingPoint>> problemStrokes,
    required List<List<DrawingPoint>> solutionStrokes,
  }) async {
    final userProblemDoc =
        _firestore.collection('userProblemData').doc('${userId}_${problemId}');

    // 트랜잭션 시작
    String attemptId = '';
    await _firestore.runTransaction((transaction) async {
      // 1. 현재 문서 상태 확인
      final docSnapshot = await transaction.get(userProblemDoc);
      final currentData = docSnapshot.data();
      final currentAttempts = currentData?['totalAttempts'] ?? 0;
      final nextAttemptNumber = currentAttempts + 1;

      // 2. 메인 문서 생성 또는 업데이트
      if (!docSnapshot.exists) {
        transaction.set(userProblemDoc, {
          'userId': userId,
          'problemId': problemId,
          'isSolved': isCorrect,
          'totalAttempts': 1,
          'correctAttempts': isCorrect ? 1 : 0,
          'lastAttemptAt': FieldValue.serverTimestamp(),
          'latestAttemptId': '', // 이후 업데이트
        });
      } else {
        transaction.update(userProblemDoc, {
          'isSolved': isCorrect || currentData!['isSolved'],
          'totalAttempts': nextAttemptNumber,
          'correctAttempts': FieldValue.increment(isCorrect ? 1 : 0),
          'lastAttemptAt': FieldValue.serverTimestamp(),
        });
      }

      // 3. attempts 컬렉션에 새로운 시도 추가
      final attemptRef = _firestore.collection('drawingAttempts').doc();
      attemptId = attemptRef.id;

      transaction.set(attemptRef, {
        'userId': userId,
        'problemId': problemId,
        'attemptId': attemptId,
        'timestamp': FieldValue.serverTimestamp(),
        'submittedAnswer': submittedAnswer,
        'isCorrect': isCorrect,
        'timeSpent': timeSpent,
        'attemptNumber': nextAttemptNumber,
      });

      // 4. userProblemData 문서에 최신 attemptId 업데이트
      transaction.update(userProblemDoc, {
        'latestAttemptId': attemptId,
      });
    });

    // 트랜잭션 완료 후 drawing data 저장
    await _saveDrawingData(attemptId, problemStrokes, solutionStrokes);
    return attemptId;
  }

  // 리뷰 모드에서의 저장 (attempts 증가 없음)
  Future<void> saveReviewState({
    required String userId,
    required String problemId,
    required List<List<DrawingPoint>> problemStrokes,
    required List<List<DrawingPoint>> solutionStrokes,
  }) async {
    final userProblemDoc =
        _firestore.collection('userProblemData').doc('${userId}_${problemId}');

    try {
      await _firestore.runTransaction((transaction) async {
        // 1. 현재 문서 상태 및 latestAttemptId 확인
        final docSnapshot = await transaction.get(userProblemDoc);
        if (!docSnapshot.exists) {
          throw Exception('Problem attempt data not found');
        }

        final attemptId = docSnapshot.data()?['latestAttemptId'];
        if (attemptId == null || attemptId.isEmpty) {
          throw Exception('No attempt ID found');
        }

        // 2. userProblemData 문서 업데이트
        transaction.update(userProblemDoc, {
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        });

        // 3. drawingAttempts 문서 업데이트 표시
        final attemptRef =
            _firestore.collection('drawingAttempts').doc(attemptId);
        transaction.update(attemptRef, {
          'lastReviewedAt': FieldValue.serverTimestamp(),
        });
      });

      // 트랜잭션 완료 후 drawing data 저장
      final docSnapshot = await userProblemDoc.get();
      final attemptId = docSnapshot.data()?['latestAttemptId'];
      if (attemptId != null) {
        await _saveDrawingData(attemptId, problemStrokes, solutionStrokes);
      }
    } catch (e) {
      print('Error in saveReviewState: $e');
      rethrow;
    }
  }

  // 마지막 드로잉 데이터 로드
  Future<Map<String, List<List<DrawingPoint>>>> loadLatestDrawingData({
    required String userId,
    required String problemId,
  }) async {
    // 1. 최신 attemptId 가져오기
    final docRef =
        _firestore.collection('userProblemData').doc('${userId}_${problemId}');

    final doc = await docRef.get();
    final latestAttemptId = doc.data()?['latestAttemptId'];

    if (latestAttemptId == null) {
      return {
        'problemStrokes': [],
        'solutionStrokes': [],
      };
    }

    // 2. Drawing 데이터 로드
    return await loadDrawingData(latestAttemptId);
  }

  // Drawing data 불러오기도 수정
  Future<Map<String, List<List<DrawingPoint>>>> loadDrawingData(
    String attemptId,
  ) async {
    // Problem Strokes 로드
    final problemStrokesSnapshot = await _firestore
        .collection('drawingData')
        .doc(attemptId)
        .collection('problemStrokes')
        .orderBy('index')
        .get();

    // Solution Strokes 로드
    final solutionStrokesSnapshot = await _firestore
        .collection('drawingData')
        .doc(attemptId)
        .collection('solutionStrokes')
        .orderBy('index')
        .get();

    return {
      'problemStrokes': _convertToDrawingPoints(problemStrokesSnapshot),
      'solutionStrokes': _convertToDrawingPoints(solutionStrokesSnapshot),
    };
  }

  List<List<DrawingPoint>> _convertToDrawingPoints(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final coordinates = data['coordinates'] as List;

      return coordinates
          .map((coord) => DrawingPoint(
                Offset(coord['x'], coord['y']),
                Color(data['color']),
                data['strokeWidth'],
              ))
          .toList();
    }).toList();
  }

  Future<Map<String, dynamic>?> getLatestAttemptData(
      String userId, String problemId) async {
    try {
      print("userid: {$userId}");
      print("problemid: {$problemId}");
      final QuerySnapshot attemptSnapshot = await _firestore
          .collection('drawingAttempts')
          .where('userId', isEqualTo: userId)
          .where('problemId', isEqualTo: problemId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (attemptSnapshot.docs.isEmpty) return null;

      return attemptSnapshot.docs.first.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error getting latest attempt data: $e');
      return null;
    }
  }
}
