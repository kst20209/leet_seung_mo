import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/problem_solving_page.dart';
import 'package:flutter/material.dart';

class ProblemSolveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveDrawingData(
    String attemptId,
    List<List<DrawingPoint>> problemStrokes,
    List<List<DrawingPoint>> solutionStrokes,
  ) async {
    final batch = _firestore.batch();

    for (int strokeIndex = 0;
        strokeIndex < problemStrokes.length;
        strokeIndex++) {
      final stroke = problemStrokes[strokeIndex];
      final firstPoint = stroke.first;

      // 각 stroke를 별도의 문서로 저장
      final strokeDoc = _firestore
          .collection('drawingData')
          .doc(attemptId)
          .collection('problemStrokes')
          .doc(strokeIndex.toString());

      batch.set(strokeDoc, {
        'color': firstPoint.color.value,
        'strokeWidth': firstPoint.strokeWidth,
        'coordinates': stroke
            .map((point) => {
                  'x': point.offset.dx,
                  'y': point.offset.dy,
                })
            .toList(), // 단일 배열로 저장
        'index': strokeIndex,
      });

      // 배치 크기가 500에 도달하면 커밋
      if (strokeIndex % 500 == 499) {
        await batch.commit();
      }
    }

    // 해설 영역 strokes 저장
    for (int strokeIndex = 0;
        strokeIndex < solutionStrokes.length;
        strokeIndex++) {
      final stroke = solutionStrokes[strokeIndex];
      final firstPoint = stroke.first;

      final strokeDoc = _firestore
          .collection('drawingData')
          .doc(attemptId)
          .collection('solutionStrokes') // 해설 영역용 subcollection
          .doc(strokeIndex.toString());

      batch.set(strokeDoc, {
        'color': firstPoint.color.value,
        'strokeWidth': firstPoint.strokeWidth,
        'coordinates': stroke
            .map((point) => {
                  'x': point.offset.dx,
                  'y': point.offset.dy,
                })
            .toList(),
        'index': strokeIndex,
      });

      if (strokeIndex % 500 == 499) {
        await batch.commit();
      }
    }

    // 남은 변경사항 커밋
    await batch.commit();
  }

  Future<void> saveAttempt({
    required String userId,
    required String problemId,
    required String submittedAnswer,
    required bool isCorrect,
    required int timeSpent,
    required Map<String, dynamic> drawingData,
    required List<List<DrawingPoint>> problemStrokes,
    required List<List<DrawingPoint>> solutionStrokes,
  }) async {
    final userProblemRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('problemSolveHistory')
        .doc(problemId);

    // 트랜잭션 시작
    String attemptId = '';
    await _firestore.runTransaction((transaction) async {
      // 1. 현재 시도 횟수 확인
      final problemDoc = await transaction.get(userProblemRef);
      final currentAttempts =
          problemDoc.exists ? (problemDoc.data()?['totalAttempts'] ?? 0) : 0;
      final nextAttemptNumber = currentAttempts + 1;

      // 2. problemAttempts에 새로운 시도 기록
      final attemptRef = _firestore.collection('problemAttempts').doc();
      attemptId = attemptRef.id;

      transaction.set(attemptRef, {
        'userId': userId,
        'problemId': problemId,
        'submittedAnswer': submittedAnswer,
        'isCorrect': isCorrect,
        'timeSpent': timeSpent,
        'solvedAt': FieldValue.serverTimestamp(),
        'attemptCount': nextAttemptNumber,
      });

      // 3. 유저의 problemSolveHistory 업데이트
      if (!problemDoc.exists) {
        transaction.set(userProblemRef, {
          'totalAttempts': 1,
          'lastAttemptAt': FieldValue.serverTimestamp(),
        });
      } else {
        transaction.update(userProblemRef, {
          'totalAttempts': nextAttemptNumber,
          'lastAttemptAt': FieldValue.serverTimestamp(),
        });
      }

      // 4. 시도 세부 정보 저장
      final attemptDetailRef = userProblemRef
          .collection('attempts')
          .doc(nextAttemptNumber.toString());

      transaction.set(attemptDetailRef, {
        'attemptId': attemptRef.id,
        'solvedAt': FieldValue.serverTimestamp(),
        'isCorrect': isCorrect,
        'timeSpent': timeSpent,
      });
    });

    // 트랜잭션 완료 후 drawing data 저장
    await _saveDrawingData(attemptId, problemStrokes, solutionStrokes);
  }

  // Drawing data 불러오기도 수정
  Future<Map<String, List<List<DrawingPoint>>>> loadDrawingData(
      String attemptId) async {
    Map<String, List<List<DrawingPoint>>> result = {
      'problemStrokes': [],
      'solutionStrokes': [],
    };

    // 문제 영역 strokes 로드
    final problemStrokes = await _firestore
        .collection('drawingData')
        .doc(attemptId)
        .collection('problemStrokes')
        .orderBy('index')
        .get();

    // 해설 영역 strokes 로드
    final solutionStrokes = await _firestore
        .collection('drawingData')
        .doc(attemptId)
        .collection('solutionStrokes')
        .orderBy('index')
        .get();

    result['problemStrokes'] = _convertToDrawingPoints(problemStrokes);
    result['solutionStrokes'] = _convertToDrawingPoints(solutionStrokes);

    return result;
  }

  List<List<DrawingPoint>> _convertToDrawingPoints(QuerySnapshot snapshot) {
    List<List<DrawingPoint>> strokes = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final coordinates = data['coordinates'] as List;

      List<DrawingPoint> points = coordinates
          .map((coord) => DrawingPoint(
                Offset(coord['x'], coord['y']),
                Color(data['color']),
                data['strokeWidth'],
              ))
          .toList();

      strokes.add(points);
    }

    return strokes;
  }

  // 특정 시도의 상세 정보 조회 (드로잉 데이터 포함)
  Future<Map<String, dynamic>> getAttemptDetail(String attemptId) async {
    final doc =
        await _firestore.collection('problemAttempts').doc(attemptId).get();

    return doc.data() ?? {};
  }
}
