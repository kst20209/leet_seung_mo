import 'package:cloud_firestore/cloud_firestore.dart';
import 'point_transaction_service.dart';

class ProblemSetPurchaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PointTransactionService _pointTransactionService =
      PointTransactionService();

  Future<void> purchaseProblemSet({
    required String userId,
    required String problemSetId,
    required String problemSetTitle,
    required int price,
  }) async {
    // 1. 먼저 사용자 데이터를 확인
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw Exception('사용자를 찾을 수 없습니다.');
    }

    final userData = userDoc.data() as Map<String, dynamic>;
    final currentPoints = userData['currentPoints'] as int? ?? 0;
    final purchasedSets =
        List<String>.from(userData['purchasedProblemSets'] ?? []);

    // 2. 이미 구매한 문제꾸러미인지 확인
    if (purchasedSets.contains(problemSetId)) {
      throw Exception('이미 구매한 문제꾸러미입니다.');
    }

    // 3. 포인트가 충분한지 확인
    if (currentPoints < price) {
      throw Exception('포인트가 부족합니다.');
    }

    // 4. 문제꾸러미 정보 확인
    final problemSetDoc =
        await _firestore.collection('problemSets').doc(problemSetId).get();
    if (!problemSetDoc.exists) {
      throw Exception('존재하지 않는 문제꾸러미입니다.');
    }

    try {
      // 5. 포인트 차감 트랜잭션 실행
      await _pointTransactionService.processUsage(
        userId: userId,
        points: price,
        reason: '문제꾸러미 구매: $problemSetTitle',
        metadata: {
          'problemSetId': problemSetId,
          'problemSetTitle': problemSetTitle,
          'type': 'problemSetPurchase',
        },
      );

      // 6. 구매한 문제꾸러미 목록에 추가
      await _firestore.collection('users').doc(userId).update({
        'purchasedProblemSets': FieldValue.arrayUnion([problemSetId]),
        'lastPurchasedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('구매 처리 중 오류가 발생했습니다: $e');
    }
  }

  // 구매 여부 확인
  Future<bool> hasPurchased({
    required String userId,
    required String problemSetId,
  }) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      return false;
    }

    final purchasedSets =
        List<String>.from(userDoc.data()?['purchasedProblemSets'] ?? []);
    return purchasedSets.contains(problemSetId);
  }

  // 구매 내역 조회
  Future<List<Map<String, dynamic>>> getPurchaseHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('problemSetPurchases')
          .where('userId', isEqualTo: userId)
          .orderBy('purchasedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('구매 내역 조회 중 오류가 발생했습니다: $e');
    }
  }
}
