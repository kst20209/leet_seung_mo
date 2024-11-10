import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'firebase_service.dart';

class DataRepository {
  final FirebaseService _firebaseService = FirebaseService();

  // ProblemSet 관련 메서드
  Future<List<ProblemSet>> getProblemSets() async {
    QuerySnapshot snapshot =
        await _firebaseService.getCollection('problemSets');
    return snapshot.docs
        .map((doc) => ProblemSet(
              id: doc.id,
              title: doc['title'],
              description: doc['description'],
              imageUrl: doc['imageUrl'],
              tags: List<String>.from(doc['tags']),
              subjectId: doc['subjectId'],
              price: doc['price'],
              totalProblems: doc['totalProblems'],
            ))
        .toList();
  }

  Future<void> addProblemSet(ProblemSet problemSet) async {
    await _firebaseService.addDocument('problemSets', {
      'title': problemSet.title,
      'description': problemSet.description,
      'imageUrl': problemSet.imageUrl,
      'tags': problemSet.tags,
      'subjectId': problemSet.subjectId,
      'price': problemSet.price,
      'totalProblems': problemSet.totalProblems,
    });
  }

  Future<void> updateProblemSet(ProblemSet problemSet) async {
    await _firebaseService.updateDocument('problemSets', problemSet.id, {
      'title': problemSet.title,
      'description': problemSet.description,
      'imageUrl': problemSet.imageUrl,
      'tags': problemSet.tags,
      'subjectId': problemSet.subjectId,
      'price': problemSet.price,
      'totalProblems': problemSet.totalProblems,
    });
  }

  Future<void> deleteProblemSet(String id) async {
    await _firebaseService.deleteDocument('problemSets', id);
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
              imageUrl: doc['imageUrl'],
              tags: List<String>.from(doc['tags']),
              problemSetId: doc['problemSetId'],
              correctAnswer: doc['correctAnswer'],
            ))
        .toList();
  }
}
