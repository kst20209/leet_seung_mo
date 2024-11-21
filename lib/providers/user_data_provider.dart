import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firebase_service.dart';
import '../models/models.dart';
import 'problem_user_data_service.dart';

enum UserDataStatus {
  initial,
  loading,
  loaded,
  error,
}

class UserDataProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  final ProblemUserDataService _problemUserDataService =
      ProblemUserDataService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _userData;
  UserDataStatus _status = UserDataStatus.initial;
  String? _error;

  // 캐시를 위한 맵
  final Map<String, Map<String, dynamic>> _problemDataCache = {};

  UserDataProvider(this._firebaseService);

  // 기존 getters
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

  // Refresh user data
  Future<void> refreshUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firebaseService.getDocument('users', uid);
      _userData = doc.data() as Map<String, dynamic>?;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// 문제를 해결 완료 상태로 표시합니다.
  Future<void> markProblemAsSolved(
      String problemId, String attemptId, bool isCorrect) async {
    final userId = _firebaseService.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    await _problemUserDataService.markAsSolved(
      userId: userId,
      problemId: problemId,
      attemptId: attemptId,
      isCorrect: isCorrect,
    );

    // 캐시 업데이트
    if (_problemDataCache.containsKey(problemId)) {
      _problemDataCache[problemId]?['isSolved'] = true;
      _problemDataCache[problemId]?['lastAttemptId'] = attemptId;
    }

    notifyListeners();
  }

  Future<void> markProblemUnsolved(String problemId) async {
    final userId = _firebaseService.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    await _problemUserDataService.markUnsolved(
      userId: userId,
      problemId: problemId,
    );

    // 캐시 업데이트
    if (_problemDataCache.containsKey(problemId)) {
      _problemDataCache[problemId]?['isSolved'] = false;
    }

    notifyListeners();
  }

  /// 해결된 문제의 드로잉 데이터를 업데이트합니다.
  Future<void> updateSolvedProblemDrawing(
      String problemId, String attemptId) async {
    final userId = _firebaseService.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    await _problemUserDataService.updateSolvedProblemDrawing(
      userId: userId,
      problemId: problemId,
      attemptId: attemptId,
    );

    // 캐시 업데이트
    if (_problemDataCache.containsKey(problemId)) {
      _problemDataCache[problemId]?['lastAttemptId'] = attemptId;
    }

    notifyListeners();
  }

  // 특정 문제의 사용자 데이터 조회
  Future<Map<String, dynamic>?> getProblemData(String problemId) async {
    if (_problemDataCache.containsKey(problemId)) {
      return _problemDataCache[problemId];
    }

    final userId = _firebaseService.currentUser?.uid;
    if (userId == null) return null;

    try {
      final data = await _problemUserDataService.getProblemData(
        userId: userId,
        problemId: problemId,
      );

      if (data != null) {
        _problemDataCache[problemId] = data;
      }

      return data;
    } catch (e) {
      print('Error getting problem data: $e');
      return null;
    }
  }

  // 즐겨찾기 토글
  Future<bool> toggleFavorite(String problemId) async {
    final userId = _firebaseService.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    try {
      final newState = await _problemUserDataService.toggleFavorite(
        userId: userId,
        problemId: problemId,
      );

      if (_problemDataCache.containsKey(problemId)) {
        _problemDataCache[problemId]?['isFavorite'] = newState;
      }

      notifyListeners();
      return newState;
    } catch (e) {
      print('Error toggling favorite: $e');
      rethrow;
    }
  }

  // 즐겨찾기한 문제 목록 조회
  Future<List<Problem>> getFavoriteProblems() async {
    try {
      final userId = _firebaseService.currentUser?.uid;
      if (userId == null) return [];

      final favoriteIds =
          await _problemUserDataService.getFavoriteProblemIds(userId);
      if (favoriteIds.isEmpty) return [];

      final QuerySnapshot problemsSnapshot = await _firestore
          .collection('problems')
          .where(FieldPath.documentId, whereIn: favoriteIds)
          .get();

      return problemsSnapshot.docs
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
      _setError('Failed to load favorite problems: $e');
      return [];
    }
  }

  // 틀린 문제 목록 조회
  Future<List<Problem>> getIncorrectProblems() async {
    try {
      final userId = _firebaseService.currentUser?.uid;
      if (userId == null) return [];

      // lastAttemptIsCorrect = false인 문제 ID 가져오기
      final querySnapshot = await _firestore
          .collection('userProblemData')
          .where('userId', isEqualTo: userId)
          .where('lastAttemptIsCorrect', isEqualTo: false)
          .get();

      final incorrectProblemIds =
          querySnapshot.docs.map((doc) => doc['problemId'] as String).toList();
      if (incorrectProblemIds.isEmpty) return [];

      // 문제 상세 정보 가져오기
      final problemsSnapshot = await _firestore
          .collection('problems')
          .where(FieldPath.documentId, whereIn: incorrectProblemIds)
          .get();

      return problemsSnapshot.docs
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
      _setError('Failed to load incorrect problems: $e');
      return [];
    }
  }

  // 캐시 무효화
  void invalidateProblemCache(String problemId) {
    _problemDataCache.remove(problemId);
    notifyListeners();
  }

  // Get purchased problem sets
  Future<List<ProblemSet>> getPurchasedProblemSets() async {
    try {
      if (_userData == null) return [];

      final purchasedIds =
          List<String>.from(_userData?['purchasedProblemSets'] ?? []);
      if (purchasedIds.isEmpty) return [];

      List<ProblemSet> allProblemSets = [];
      for (var i = 0; i < purchasedIds.length; i += 10) {
        var end = (i + 10 < purchasedIds.length) ? i + 10 : purchasedIds.length;
        var chunk = purchasedIds.sublist(i, end);

        final querySnapshot = await _firestore
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
                  category: doc['category'],
                  subCategory: doc['subCategory'],
                  field: doc['field'],
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
      final querySnapshot = await _firestore
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
}
