import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'firebase_service.dart';

class DataRepository {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ProblemSet 받아오기
  Future<List<ProblemSet>> getProblemSets() async {
    // isActive가 true인 문서들 가져오기
    final snapshot = await _firestore
        .collection('problemSets')
        .where('isActive', isEqualTo: true)
        .get();

    // isActive가 null인 문서들 가져오기
    final nullActiveSnapshot = await _firestore
        .collection('problemSets')
        .where('isActive', isNull: true)
        .get();

    // null인 문서들의 isActive를 false로 업데이트
    final batch = _firestore.batch();
    for (var doc in nullActiveSnapshot.docs) {
      batch.update(_firestore.collection('problemSets').doc(doc.id), {
        'isActive': false,
      });
    }
    await batch.commit();

    return snapshot.docs.map((doc) {
      var data = doc.data();
      return ProblemSet(
        id: doc.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        tags: List<String>.from(data['tags'] ?? []),
        subjectId: data['subjectId'] ?? '',
        price: data['price'] ?? 0,
        totalProblems: data['totalProblems'] ?? 0,
        category: data['category'] ?? '',
        subCategory: data['subCategory'] ?? '',
        field: data['field'] ?? '',
      );
    }).toList();
  }

  // Problem 관련 메서드
  Future<List<Problem>> getProblems(String problemSetId) async {
    QuerySnapshot snapshot = await _firebaseService.getCollection('problems');
    return snapshot.docs
        .where((doc) => doc['problemSetId'] == problemSetId)
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
              isWideSolution: doc['isWideSolution'] as bool? ?? false,
            ))
        .toList();
  }
}
