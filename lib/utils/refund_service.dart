// refund_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import './point_transaction_service.dart';

class RefundService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PointTransactionService _pointTransactionService =
      PointTransactionService();

  Future<void> processProblemSetRefund({
    required String userId,
    required String problemSetId,
    required String problemSetTitle,
    required int refundAmount,
  }) async {
    final String transactionId = const Uuid().v4();

    try {
      // 트랜잭션 외부에서 먼저 문제 ID 조회
      final problemsSnapshot = await _firestore
          .collection('problems')
          .where('problemSetId', isEqualTo: problemSetId)
          .limit(1)
          .get();

      if (problemsSnapshot.docs.isEmpty) {
        throw Exception('문제꾸러미에 문제가 없습니다.');
      }

      final firstProblemId = problemsSnapshot.docs.first.id;

      await _firestore.runTransaction((transaction) async {
        // 1. 사용자 문서 확인
        final userDoc =
            await transaction.get(_firestore.collection('users').doc(userId));

        if (!userDoc.exists) {
          throw Exception('사용자를 찾을 수 없습니다.');
        }

        // 2. 구매 여부 확인
        final purchasedSets =
            List<String>.from(userDoc.data()?['purchasedProblemSets'] ?? []);
        if (!purchasedSets.contains(problemSetId)) {
          throw Exception('구매하지 않은 문제꾸러미입니다.');
        }

        // 3. firstViewedAt 확인하여 환불 가능 여부 체크
        final viewDoc = await transaction.get(_firestore
            .collection('userProblemData')
            .doc('${userId}_${firstProblemId}'));

        if (viewDoc.exists && viewDoc.data()?['firstViewedAt'] != null) {
          final firstViewedAt = viewDoc.data()?['firstViewedAt'] as Timestamp;
          final now = Timestamp.now();
          final hoursSinceFirstView =
              now.toDate().difference(firstViewedAt.toDate()).inDays;

          if (hoursSinceFirstView > 7) {
            throw Exception('최초 구매 후 7일이 지나 환불이 불가능합니다.');
          }
        }

        // 4. 포인트 환불 트랜잭션 데이터 생성
        final transactionData = {
          'userId': userId,
          'points': refundAmount,
          'type': PointTransactionType.refund.toString(),
          'reason': '문제꾸러미 환불: $problemSetTitle',
          'metadata': {
            'problemSetId': problemSetId,
            'problemSetTitle': problemSetTitle,
            'transactionId': transactionId,
            'refundType': 'problemSet',
          },
          'status': TransactionStatus.completed.toString(),
          'transactionId': transactionId,
          'createdAt': FieldValue.serverTimestamp(),
          'completedAt': FieldValue.serverTimestamp(),
        };

        // 5. pointTransactions 컬렉션에 저장
        transaction.set(
            _firestore.collection('pointTransactions').doc(transactionId),
            transactionData);

        // 6. 사용자의 transactions 서브컬렉션에 저장
        transaction.set(
            _firestore
                .collection('users')
                .doc(userId)
                .collection('transactions')
                .doc(transactionId),
            transactionData);

        // 7. 사용자 문서 업데이트
        transaction.update(userDoc.reference, {
          'currentPoints': FieldValue.increment(refundAmount),
          'purchasedProblemSets': FieldValue.arrayRemove([problemSetId]),
          'totalRefundedPoints': FieldValue.increment(refundAmount),
          'lastRefundedAt': FieldValue.serverTimestamp(),
        });

        // 8. 환불 이력 저장
        transaction
            .set(_firestore.collection('refundHistory').doc(transactionId), {
          ...transactionData,
          'processedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('환불 처리 중 오류가 발생했습니다: $e');
    }
  }

  // 환불 가능 여부 확인 메서드
  Future<bool> isRefundable({
    required String userId,
    required String problemSetId,
  }) async {
    try {
      // 1. 문제 목록 조회
      final problemsSnapshot = await _firestore
          .collection('problems')
          .where('problemSetId', isEqualTo: problemSetId)
          .limit(1)
          .get();

      if (problemsSnapshot.docs.isEmpty) {
        return false;
      }

      // 2. 첫 번째 문제의 조회 시점 확인
      final firstProblemId = problemsSnapshot.docs.first.id;
      final viewDoc = await _firestore
          .collection('userProblemData')
          .doc('${userId}_${firstProblemId}')
          .get();

      if (!viewDoc.exists || viewDoc.data()?['firstViewedAt'] == null) {
        return true; // 아직 조회하지 않았다면 환불 가능
      }

      // 3. 24시간 이내 확인
      final firstViewedAt = viewDoc.data()?['firstViewedAt'] as Timestamp;
      final now = Timestamp.now();
      final hoursSinceFirstView =
          now.toDate().difference(firstViewedAt.toDate()).inDays;

      return hoursSinceFirstView <= 7;
    } catch (e) {
      print('환불 가능 여부 확인 중 오류: $e');
      return false;
    }
  }
}
