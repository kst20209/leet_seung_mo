import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leet_seung_mo/providers/memory_data_cache.dart';
import 'package:leet_seung_mo/utils/sort_service.dart';
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

  final ValueNotifier<UserDataStatus> statusNotifier =
      ValueNotifier(UserDataStatus.initial);

  final _cache = MemoryDataCache();

  Map<String, dynamic>? _userData;
  UserDataStatus _status = UserDataStatus.initial;
  String? _error;

  UserDataProvider(this._firebaseService);

  // 기존 getters
  Map<String, dynamic>? get userData => _userData;
  UserDataStatus get status => _status;
  String? get error => _error;
  String? get nickname => _userData?['nickname'] as String?;
  int get points => _userData?['currentPoints'] ?? 0;

  //문제 관련
  List<ProblemSet>? _purchasedProblemSets;
  List<Problem>? _favoriteProblems;
  List<Problem>? _incorrectProblems;
  bool _isLoadingProblems = false;

  List<ProblemSet> get purchasedProblemSets => _purchasedProblemSets ?? [];
  List<Problem> get favoriteProblems => _favoriteProblems ?? [];
  List<Problem> get incorrectProblems => _incorrectProblems ?? [];
  bool get isLoadingProblems => _isLoadingProblems;

  final ValueNotifier<bool> loadingProblemSets = ValueNotifier(false);
  final ValueNotifier<bool> loadingFavorites = ValueNotifier(false);
  final ValueNotifier<bool> loadingIncorrect = ValueNotifier(false);

  @override
  void dispose() {
    loadingProblemSets.dispose();
    loadingFavorites.dispose();
    loadingIncorrect.dispose();
    statusNotifier.dispose();
    super.dispose();
  }

  Future<void> loadAllProblemData() async {
    if (_isLoadingProblems) return;
    _isLoadingProblems = true;
    notifyListeners();

    try {
      _purchasedProblemSets = await getPurchasedProblemSets();
      _favoriteProblems = await getFavoriteProblems();
      _incorrectProblems = await getIncorrectProblems();
    } finally {
      _isLoadingProblems = false;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    _status = UserDataStatus.error;
  }

  // 초기 데이터 로드
  Future<void> loadUserData(String uid) async {
    try {
      statusNotifier.value = UserDataStatus.loading;

      DocumentSnapshot doc = await _firebaseService.getDocument('users', uid);
      final newData = doc.data() as Map<String, dynamic>?;

      if (!mapEquals(_userData, newData)) {
        _userData = newData;
        notifyListeners();
      }
      statusNotifier.value = UserDataStatus.loaded;
    } catch (e) {
      _error = e.toString();
      statusNotifier.value = UserDataStatus.error;
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
      invalidateCache('all');
      DocumentSnapshot doc = await _firebaseService.getDocument('users', uid);
      _userData = doc.data() as Map<String, dynamic>?;
      _purchasedProblemSets = await getPurchasedProblemSets();
      notifyListeners();
    } catch (e) {
      _setError("오류가 발생했습니다: ${e.toString()}");
    }
  }

  // 캐시 무효화 메서드
  void invalidateCache(String type) {
    switch (type) {
      case 'all':
        _cache.clear();
        break;
      case 'problemSets':
        _cache.remove('problemSets:purchased');
        break;
      case 'favorites':
        _cache.remove('problems:favorites');
        break;
    }
    notifyListeners();
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
    final cacheKey = 'problems:$problemId';
    final problemData = _cache.get<Map<String, dynamic>>(cacheKey);
    if (problemData != null) {
      final updatedData = Map<String, dynamic>.from(problemData);
      updatedData['isSolved'] = true;
      updatedData['lastAttemptId'] = attemptId;
      _cache.set(cacheKey, updatedData);
    }

    // 틀린 문제 목록 캐시 무효화
    _cache.remove('problems:incorrect');

    if (isCorrect != true) {
      _incorrectProblems = await getIncorrectProblems();
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
    final cacheKey = 'problems:$problemId';
    final problemData = _cache.get<Map<String, dynamic>>(cacheKey);
    if (problemData != null) {
      final updatedData = Map<String, dynamic>.from(problemData);
      updatedData['isSolved'] = false;
      _cache.set(cacheKey, updatedData);
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
    final cacheKey = 'problems:$problemId';
    final problemData = _cache.get<Map<String, dynamic>>(cacheKey);
    if (problemData != null) {
      final updatedData = Map<String, dynamic>.from(problemData);
      updatedData['lastAttemptId'] = attemptId;
      _cache.set(cacheKey, updatedData);
    }

    notifyListeners();
  }

  // 특정 문제의 사용자 데이터 조회
  Future<Map<String, dynamic>?> getProblemData(String problemId) async {
    final cacheKey = 'problems:$problemId';
    final cachedData = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cachedData != null) return cachedData;

    final userId = _firebaseService.currentUser?.uid;
    if (userId == null) return null;

    try {
      final data = await _problemUserDataService.getProblemData(
        userId: userId,
        problemId: problemId,
      );

      if (data != null) {
        _cache.set(cacheKey, data);
      }

      return data;
    } catch (e) {
      _setError('데이터를 로드하는 과정에서 오류가 발생했습니다: $e');
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

      _cache.remove('problems:favorites');

      _favoriteProblems = await getFavoriteProblems();
      notifyListeners();
      return newState;
    } catch (e) {
      _setError('오류가 발생했습니다: $e');
      rethrow;
    }
  }

  // 즐겨찾기한 문제 목록 조회
  Future<List<Problem>> getFavoriteProblems() async {
    try {
      final userId = _firebaseService.currentUser?.uid;
      if (userId == null) return [];

      // 캐시 확인
      final cacheKey = 'problems:favorites';
      final cachedData = _cache.get<List<Problem>>(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }

      final favoriteIds =
          await _problemUserDataService.getFavoriteProblemIds(userId);

      if (favoriteIds.isEmpty) return [];

      List<Problem> allFavoriteProblems = [];

      // 10개씩 청크로 나누어 처리
      // TODO: 무한 스크롤 구현
      for (var i = 0; i < favoriteIds.length; i += 10) {
        var end = (i + 10 < favoriteIds.length) ? i + 10 : favoriteIds.length;
        var chunk = favoriteIds.sublist(i, end);

        final QuerySnapshot problemsSnapshot = await _firestore
            .collection('problems')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        final chunkProblems = problemsSnapshot.docs
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
                  isWideSolution: (doc.data() as Map<String, dynamic>?)
                              ?.containsKey('isWideSolution') ==
                          true
                      ? (doc['isWideSolution'] as bool?) ?? false
                      : false,
                ))
            .toList();

        allFavoriteProblems.addAll(chunkProblems);
      }

      // 캐시에 저장
      _cache.set(cacheKey, allFavoriteProblems);

      return allFavoriteProblems;
    } catch (e) {
      _setError('즐겨찾기한 문제를 로드하는 과정에서 오류가 발생했습니다: $e');
      return [];
    }
  }

  // 틀린 문제 목록 조회
  Future<List<Problem>> getIncorrectProblems() async {
    final cacheKey = 'problems:incorrect';

    try {
      final userId = _firebaseService.currentUser?.uid;
      if (userId == null) return [];

      final cachedData = _cache.get<List<Problem>>(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }

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
      // TODO: 무한 스크롤 구현
      List<Problem> allIncorrectProblems = [];
      for (var i = 0; i < incorrectProblemIds.length; i += 10) {
        var end = (i + 10 < incorrectProblemIds.length)
            ? i + 10
            : incorrectProblemIds.length;
        var chunk = incorrectProblemIds.sublist(i, end);

        final problemsSnapshot = await _firestore
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
                  isWideSolution: doc.data().containsKey('isWideSolution')
                      ? doc['isWideSolution'] as bool
                      : false,
                ))
            .toList();

        allIncorrectProblems.addAll(problems);
      }

      // 캐시에 저장
      _cache.set(cacheKey, allIncorrectProblems);

      return allIncorrectProblems;
    } catch (e) {
      _setError('오답노트 문제를 받아오는 과정에서 오류가 발생했습니다: $e');
      return [];
    }
  }

  // Get purchased problem sets
  Future<List<ProblemSet>> getPurchasedProblemSets() async {
    final timeout = DateTime.now().add(Duration(seconds: 10));
    final cacheKey = 'problemSets:purchased';

    try {
      // 캐시된 데이터 확인
      final cachedData = _cache.get<List<ProblemSet>>(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }

      while (_userData == null) {
        if (DateTime.now().isAfter(timeout)) {
          _setError('TimeOut 에러가 발생했습니다.');
          return [];
        }
        if (_status == UserDataStatus.error) {
          _setError('사용자 데이터 로드에 실패했습니다.');
          return [];
        }
        await Future.delayed(Duration(milliseconds: 100));
      }

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
      final sortedProblemSets = SortService().sortProblemSets(allProblemSets);
      _cache.set(cacheKey, sortedProblemSets);

      return sortedProblemSets;
    } catch (e) {
      _setError('구입 문제꾸러미를 불러오는데 실패했습니다: $e');
      return [];
    }
  }

  // Get problems by problem set ID
  Future<List<Problem>> getProblemsByProblemSetId(String problemSetId) async {
    final cacheKey = 'problemSets:$problemSetId:problems';

    try {
      // 캐시된 데이터 확인
      final cachedData = _cache.get<List<Problem>>(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }

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
                isWideSolution: doc.data().containsKey('isWideSolution')
                    ? doc['isWideSolution'] as bool
                    : false,
              ))
          .toList();
    } catch (e) {
      _setError('문제를 로드하는데 실패했습니다: $e');
      return [];
    }
  }
}
