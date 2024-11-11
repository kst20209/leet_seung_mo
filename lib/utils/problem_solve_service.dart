import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/problem_solving_page.dart';
import 'package:flutter/material.dart';

class ProblemSolveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveDrawingData(
    String attemptId,
    List<List<DrawingPoint>> strokes,
  ) async {
    final batch = _firestore.batch();

    for (int strokeIndex = 0; strokeIndex < strokes.length; strokeIndex++) {
      final stroke = strokes[strokeIndex];
      final firstPoint = stroke.first;

      // 각 stroke를 별도의 문서로 저장
      final strokeDoc = _firestore
          .collection('drawingData')
          .doc(attemptId)
          .collection('strokes')
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

    // 남은 변경사항 커밋
    if (strokes.length % 500 != 0) {
      await batch.commit();
    }
  }

  Future<void> saveAttempt({
    required String userId,
    required String problemId,
    required String submittedAnswer,
    required bool isCorrect,
    required int timeSpent,
    required Map<String, dynamic> drawingData,
    required List<List<DrawingPoint>> strokes,
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
        'strokesCount': strokes.length,
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
    await _saveDrawingData(attemptId, strokes);
  }

  // Drawing data 불러오기
  Future<List<List<DrawingPoint>>> loadDrawingData(String attemptId) async {
    final chunks = await _firestore
        .collection('drawingData')
        .doc(attemptId)
        .collection('chunks')
        .orderBy('index')
        .get();

    List<List<DrawingPoint>> allStrokes = [];

    for (var chunk in chunks.docs) {
      final strokesData = chunk.data()['strokes'] as List;

      for (var strokeData in strokesData) {
        final points = (strokeData['p'] as List).map((point) {
          return DrawingPoint(
            Offset(point[0], point[1]),
            Color(strokeData['c']),
            strokeData['w'],
          );
        }).toList();

        allStrokes.add(points);
      }
    }

    return allStrokes;
  }

  // 특정 시도의 상세 정보 조회 (드로잉 데이터 포함)
  Future<Map<String, dynamic>> getAttemptDetail(String attemptId) async {
    final doc =
        await _firestore.collection('problemAttempts').doc(attemptId).get();

    return doc.data() ?? {};
  }
}
