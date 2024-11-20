import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';

class HomeDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 활성 프로모션 배너 데이터 가져오기
  Future<List<Map<String, dynamic>>> getActivePromotions() async {
    try {
      final now = Timestamp.now();

      final snapshot = await _firestore
          .collection('promoBanners')
          .where('active', isEqualTo: true)
          .where('startDate', isLessThanOrEqualTo: now)
          .where('endDate', isGreaterThan: now)
          .orderBy('startDate')
          .orderBy('order')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'imageUrl': data['imageUrl'] as String,
          'title': data['title'] as String,
          'subtitle': data['subtitle'] as String,
          'action': data['action'] as Map<String, dynamic>?,
        };
      }).toList();
    } catch (e) {
      print('Error getting promotions: $e');
      return [];
    }
  }

  // 오늘의 무료 문제 가져오기
  Future<List<Problem>> getTodayFreeProblems() async {
    try {
      final now = Timestamp.now();

      // 활성화된 무료 문제 ID 가져오기
      final freeProblemSnapshot = await _firestore
          .collection('freeProblems')
          .where('active', isEqualTo: true)
          .where('startDate', isLessThanOrEqualTo: now)
          .where('endDate', isGreaterThan: now)
          .orderBy('startDate')
          .orderBy('order')
          .get();

      // 문제 ID 리스트 추출
      final problemIds = freeProblemSnapshot.docs
          .map((doc) => doc.data()['problemId'] as String)
          .toList();

      if (problemIds.isEmpty) return [];

      // 문제 상세 정보 가져오기
      final problemsSnapshot = await _firestore
          .collection('problems')
          .where(FieldPath.documentId, whereIn: problemIds)
          .get();

      // Problem 객체로 변환
      final problems = problemsSnapshot.docs
          .map((doc) => Problem(
                id: doc.id,
                title: doc['title'],
                description: doc['description'],
                problemImage: doc['problemImage'],
                solutionImage: doc['solutionImage'],
                imageUrl: doc['imageUrl'],
                tags: List<String>.from(doc['tags']),
                problemSetId: doc['problemSetId'],
                correctAnswer: doc['correctAnswer'],
              ))
          .toList();

      // order 순서대로 정렬
      final orderMap = {
        for (var doc in freeProblemSnapshot.docs)
          doc.data()['problemId'] as String: doc.data()['order'] as num
      };

      problems.sort((a, b) {
        final orderA = orderMap[a.id] ?? 0;
        final orderB = orderMap[b.id] ?? 0;
        return orderA.compareTo(orderB);
      });

      return problems;
    } catch (e) {
      print('Error getting free problems: $e');
      return [];
    }
  }

  // 프로모션 액션 실행 도우미 메소드
  void handlePromotionAction(
      BuildContext context, Map<String, dynamic>? action) {
    if (action == null) return;

    switch (action['type']) {
      case 'page':
        Navigator.pushNamed(context, action['value']);
        break;
      case 'url':
        // URL 처리 로직 (외부 브라우저 열기 등)
        break;
      case 'review':
        // 앱 스토어 리뷰 페이지로 이동하는 로직
        break;
    }
  }
}
