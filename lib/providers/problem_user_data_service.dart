import 'package:cloud_firestore/cloud_firestore.dart';

/// ProblemUserDataService는 사용자별 문제 데이터를 관리하는 서비스입니다.
///
/// 주요 기능:
/// - 문제 풀이 상태 관리 (isSolved)
/// - 즐겨찾기 관리 (isFavorite)
/// - 사용자별 문제 통계 조회
///
/// 데이터 구조 (`userProblemData` 컬렉션):
/// ```
/// userProblemData/
/// ├─ {userId}_{problemId}/
/// │   ├─ userId: String
/// │   ├─ problemId: String
/// │   ├─ isSolved: boolean
/// │   ├─ isFavorite: boolean
/// │   ├─ totalAttempts: number
/// │   ├─ correctAttempts: number
/// │   ├─ lastAttemptAt: timestamp
/// │   ├─ latestAttemptId: string
/// │   └─ createdAt: timestamp
/// ```
class ProblemUserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 사용자의 특정 문제 데이터를 조회합니다.
  Future<Map<String, dynamic>?> getProblemData({
    required String userId,
    required String problemId,
  }) async {
    final docRef = _getDocumentRef(userId, problemId);
    final doc = await docRef.get();
    return doc.data() as Map<String, dynamic>?;
  }

  /// 문제의 풀이 상태를 가져옵니다.
  Future<bool> isSolved({
    required String userId,
    required String problemId,
  }) async {
    final data = await getProblemData(
      userId: userId,
      problemId: problemId,
    );
    return data?['isSolved'] ?? false;
  }

  /// 문제의 즐겨찾기 상태를 가져옵니다.
  Future<bool> isFavorite({
    required String userId,
    required String problemId,
  }) async {
    final data = await getProblemData(
      userId: userId,
      problemId: problemId,
    );
    return data?['isFavorite'] ?? false;
  }

  /// 문제의 즐겨찾기 상태를 토글합니다.
  Future<bool> toggleFavorite({
    required String userId,
    required String problemId,
  }) async {
    final docRef = _getDocumentRef(userId, problemId);
    bool newValue = false;

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);

      if (!doc.exists) {
        // 문서가 없을 경우 새로 생성
        newValue = true;
        transaction.set(docRef, {
          'userId': userId,
          'problemId': problemId,
          'isFavorite': true,
          'isSolved': false,
          'totalAttempts': 0,
          'correctAttempts': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // 기존 즐겨찾기 상태를 토글
        final data = doc.data() as Map<String, dynamic>?;
        newValue = !(data?['isFavorite'] ?? false);
        transaction.update(docRef, {'isFavorite': newValue});
      }
    });

    return newValue;
  }

  /// 특정 사용자의 즐겨찾기한 문제 ID 목록을 가져옵니다.
  Future<List<String>> getFavoriteProblemIds(String userId) async {
    final querySnapshot = await _firestore
        .collection('userProblemData')
        .where('userId', isEqualTo: userId)
        .where('isFavorite', isEqualTo: true)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data()['problemId'] as String)
        .toList();
  }

  /// 특정 사용자가 해결한 문제 ID 목록을 가져옵니다.
  Future<List<String>> getSolvedProblemIds(String userId) async {
    final querySnapshot = await _firestore
        .collection('userProblemData')
        .where('userId', isEqualTo: userId)
        .where('isSolved', isEqualTo: true)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data()['problemId'] as String)
        .toList();
  }

  /// 문제 풀이 통계를 가져옵니다.
  Future<Map<String, dynamic>> getProblemStats({
    required String userId,
    required String problemId,
  }) async {
    final data = await getProblemData(
      userId: userId,
      problemId: problemId,
    );

    return {
      'totalAttempts': data?['totalAttempts'] ?? 0,
      'correctAttempts': data?['correctAttempts'] ?? 0,
      'lastAttemptAt': data?['lastAttemptAt'],
    };
  }

  /// 문서 참조를 가져오는 헬퍼 메서드
  DocumentReference _getDocumentRef(String userId, String problemId) {
    return _firestore
        .collection('userProblemData')
        .doc('${userId}_${problemId}');
  }

  /// 사용자의 풀이 진행 상황을 가져옵니다.
  Future<Map<String, dynamic>> getUserProgress(String userId) async {
    final querySnapshot = await _firestore
        .collection('userProblemData')
        .where('userId', isEqualTo: userId)
        .get();

    int totalSolved = 0;
    int totalAttempted = 0;
    int totalFavorites = 0;

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      if (data['isSolved'] == true) totalSolved++;
      if (data['totalAttempts'] > 0) totalAttempted++;
      if (data['isFavorite'] == true) totalFavorites++;
    }

    return {
      'totalSolved': totalSolved,
      'totalAttempted': totalAttempted,
      'totalFavorites': totalFavorites,
    };
  }
}
