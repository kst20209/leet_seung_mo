import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firebase_service.dart';

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

  // Getters
  Map<String, dynamic>? get userData => _userData;
  UserDataStatus get status => _status;
  String? get error => _error;
  String? get nickname => _userData?['nickname'] as String?;
  int get points => _userData?['currentPoints'] ?? 0;

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

  // 데이터 새로고침
  Future<void> refreshUserData(String uid) async {
    return loadUserData(uid);
  }

  // 포인트 사용
  Future<void> usePoints(String uid, int amount, String reason) async {
    if (points < amount) {
      throw Exception('포인트가 부족합니다');
    }
    // Optimistic update
    final previousPoints = points;
    try {
      _userData = {
        ...?_userData,
        'currentPoints': points - amount,
      };
      notifyListeners();

      // Firestore update
      await _firebaseService.updateDocument('users', uid, {
        'currentPoints': FieldValue.increment(-amount),
        'pointHistory': FieldValue.arrayUnion([
          {
            'timestamp': FieldValue.serverTimestamp(),
            'amount': -amount,
            'reason': reason,
          }
        ]),
      });
    } catch (e) {
      // Rollback on error
      _userData = {
        ...?_userData,
        'currentPoints': previousPoints,
      };
      notifyListeners();
      rethrow;
    }
  }

  // 포인트 추가
  Future<void> addPoints(String uid, int amount, String reason) async {
    // Optimistic update
    final previousPoints = points;
    try {
      _userData = {
        ...?_userData,
        'currentPoints': points + amount,
      };
      notifyListeners();

      // Firestore update
      await _firebaseService.updateDocument('users', uid, {
        'currentPoints': FieldValue.increment(amount),
        'pointHistory': FieldValue.arrayUnion([
          {
            'timestamp': FieldValue.serverTimestamp(),
            'amount': amount,
            'reason': reason,
          }
        ]),
      });
    } catch (e) {
      // Rollback on error
      _userData = {
        ...?_userData,
        'currentPoints': previousPoints,
      };
      notifyListeners();
      rethrow;
    }
  }

  // 문제 구매
  Future<void> purchaseProblemSet(
      String uid, String problemSetId, int price) async {
    try {
      await usePoints(uid, price, 'Purchase ProblemSet: $problemSetId');

      await _firebaseService.updateDocument('users', uid, {
        'purchasedProblemSets': FieldValue.arrayUnion([problemSetId]),
      });

      _userData = {
        ...?_userData,
        'purchasedProblemSets': [
          ...(_userData?['purchasedProblemSets'] ?? []),
          problemSetId,
        ],
      };
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
