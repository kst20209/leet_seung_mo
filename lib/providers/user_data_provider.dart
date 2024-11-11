import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firebase_service.dart';
import '../models/models.dart';

enum UserDataStatus {
  initial,
  loading,
  loaded,
  error,
}

class UserDataProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  Map<String, dynamic>? _userData;
  UserDataStatus _status = UserDataStatus.initial;
  String? _error;

  UserDataProvider(this._firebaseService);

  // Existing getters
  Map<String, dynamic>? get userData => _userData;
  UserDataStatus get status => _status;
  String? get error => _error;
  String? get nickname => _userData?['nickname'] as String?;
  int get points => _userData?['currentPoints'] ?? 0;

  void _setError(String error) {
    _error = error;
    _status = UserDataStatus.error;
    notifyListeners();
  }

  // 초기 데이터 로드
  Future<void> loadUserData(String uid) async {
    try {
      _status = UserDataStatus.loading;
      notifyListeners();

      DocumentSnapshot doc = await _firebaseService.getDocument('users', uid);
      _userData = doc.data() as Map<String, dynamic>?;
      _status = UserDataStatus.loaded;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _status = UserDataStatus.error;
      notifyListeners();
    }
  }

  // 데이터 초기화
  void clearData() {
    _userData = null;
    _status = UserDataStatus.initial;
    _error = null;
    notifyListeners();
  }

  // Get purchased problem sets
  Future<List<ProblemSet>> getPurchasedProblemSets() async {
    try {
      if (_userData == null) {
        return [];
      }

      final purchasedIds =
          List<String>.from(_userData?['purchasedProblemSets'] ?? []);
      if (purchasedIds.isEmpty) {
        return [];
      }

      // Firebase는 whereIn에 최대 10개의 값만 허용하므로,
      // 필요한 경우 청크로 나누어 요청
      List<ProblemSet> allProblemSets = [];
      for (var i = 0; i < purchasedIds.length; i += 10) {
        var end = (i + 10 < purchasedIds.length) ? i + 10 : purchasedIds.length;
        var chunk = purchasedIds.sublist(i, end);

        final querySnapshot = await FirebaseFirestore.instance
            .collection('problemSets')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        final problemSets = querySnapshot.docs
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

        allProblemSets.addAll(problemSets);
      }

      return allProblemSets;
    } catch (e) {
      _setError('Failed to load purchased problem sets: $e');
      return [];
    }
  }

  // Get problems by problem set ID
  Future<List<Problem>> getProblemsByProblemSetId(String problemSetId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('problems')
          .where('problemSetId', isEqualTo: problemSetId)
          .get();

      return querySnapshot.docs
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
    } catch (e) {
      _setError('Failed to load problems: $e');
      return [];
    }
  }

  // Refresh user data
  Future<void> refreshUserData(String uid) async {
    try {
      _status = UserDataStatus.loading;
      notifyListeners();

      DocumentSnapshot doc = await _firebaseService.getDocument('users', uid);
      _userData = doc.data() as Map<String, dynamic>?;
      _status = UserDataStatus.loaded;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Get recently solved problems
  Future<List<Problem>> getRecentlySolvedProblems() async {
    try {
      if (_userData == null) {
        return [];
      }

      final recentProblemIds =
          List<String>.from(_userData?['lastSolvedProblems'] ?? []);
      if (recentProblemIds.isEmpty) {
        return [];
      }

      List<Problem> allProblems = [];
      for (var i = 0; i < recentProblemIds.length; i += 10) {
        var end = (i + 10 < recentProblemIds.length)
            ? i + 10
            : recentProblemIds.length;
        var chunk = recentProblemIds.sublist(i, end);

        final querySnapshot = await FirebaseFirestore.instance
            .collection('problems')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        final problems = querySnapshot.docs
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

        allProblems.addAll(problems);
      }

      return allProblems;
    } catch (e) {
      _setError('Failed to load recently solved problems: $e');
      return [];
    }
  }

  // Get favorite problems
  Future<List<Problem>> getFavoriteProblems() async {
    try {
      final userId = _firebaseService.currentUser?.uid;
      if (userId == null) {
        return [];
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('userSolvedProblems')
          .where('userId', isEqualTo: userId)
          .where('isLiked', isEqualTo: true)
          .get();

      final favoriteIds =
          querySnapshot.docs.map((doc) => doc['problemId'] as String).toList();
      if (favoriteIds.isEmpty) {
        return [];
      }

      List<Problem> allProblems = [];
      for (var i = 0; i < favoriteIds.length; i += 10) {
        var end = (i + 10 < favoriteIds.length) ? i + 10 : favoriteIds.length;
        var chunk = favoriteIds.sublist(i, end);

        final problemsSnapshot = await FirebaseFirestore.instance
            .collection('problems')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

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

        allProblems.addAll(problems);
      }

      return allProblems;
    } catch (e) {
      _setError('Failed to load favorite problems: $e');
      return [];
    }
  }
}
