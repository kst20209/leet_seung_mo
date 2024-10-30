import 'package:cloud_firestore/cloud_firestore.dart';

enum PointTransactionType {
  purchase, // 현금으로 구매
  reward, // 보상 (이벤트, 출석체크 등)
  usage, // 사용 (문제 구매 등)
  refund, // 환불
  adjustment, // 관리자 조정
}

class PointTransaction {
  final String userId;
  final int points;
  final int? bonusPoints;
  final PointTransactionType type;
  final String reason;
  final Map<String, dynamic> metadata;

  PointTransaction({
    required this.userId,
    required this.points,
    this.bonusPoints = 0,
    required this.type,
    required this.reason,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'points': points,
        'bonusPoints': bonusPoints,
        'type': type.toString(),
        'reason': reason,
        'metadata': metadata,
        'timestamp': FieldValue.serverTimestamp(),
      };
}

class PointTransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> processTransaction(PointTransaction transaction) async {
    final batch = _firestore.batch();
    final totalPoints = transaction.points + (transaction.bonusPoints ?? 0);

    try {
      // 1. 먼저 현재 사용자의 포인트를 가져옵니다
      final userDoc =
          await _firestore.collection('users').doc(transaction.userId).get();
      final currentPoints = userDoc.data()?['currentPoints'] ?? 0;
      final newBalance = currentPoints + totalPoints;

      // 2. 전체 트랜잭션 로그 기록 (timestamp 포함)
      final transactionRef = _firestore.collection('pointTransactions').doc();
      final transactionData = {
        ...transaction.toJson(),
        'transactionId': transactionRef.id,
        'balance': newBalance,
        'timestamp': FieldValue.serverTimestamp(),
      };
      batch.set(transactionRef, transactionData);

      // 3. 사용자 포인트 업데이트와 히스토리용 데이터 준비
      Map<String, dynamic> historyEntry = {
        'userId': transaction.userId,
        'points': transaction.points,
        'bonusPoints': transaction.bonusPoints,
        'type': transaction.type.toString(),
        'reason': transaction.reason,
        'metadata': transaction.metadata,
        'balance': newBalance,
        'transactionId': transactionRef.id,
      };

      final userRef = _firestore.collection('users').doc(transaction.userId);
      batch.update(userRef, {
        'currentPoints': FieldValue.increment(totalPoints),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // 4. 트랜잭션 타입별 추가 처리
      switch (transaction.type) {
        case PointTransactionType.purchase:
          batch.update(userRef, {
            'totalPurchasedPoints': FieldValue.increment(totalPoints),
            'totalSpentAmount':
                FieldValue.increment(transaction.metadata['price'] as int),
          });
          await batch.commit();

          // 히스토리는 batch 커밋 후 별도로 업데이트
          await userRef.update({
            'pointTransactionHistory': FieldValue.arrayUnion([historyEntry]),
          });
          break;

        case PointTransactionType.reward:
          batch.update(userRef, {
            'totalRewardPoints': FieldValue.increment(totalPoints),
          });
          await batch.commit();

          // 히스토리는 batch 커밋 후 별도로 업데이트
          await userRef.update({
            'rewardHistory': FieldValue.arrayUnion([historyEntry]),
          });
          break;

        case PointTransactionType.usage:
          batch.update(userRef, {
            'totalUsedPoints': FieldValue.increment(totalPoints.abs()),
          });
          await batch.commit();

          // 히스토리는 batch 커밋 후 별도로 업데이트
          await userRef.update({
            'pointTransactionHistory': FieldValue.arrayUnion([historyEntry]),
          });
          break;

        default:
          await batch.commit();
          // 기본적으로도 트랜잭션 히스토리는 기록
          await userRef.update({
            'pointTransactionHistory': FieldValue.arrayUnion([historyEntry]),
          });
          break;
      }
    } catch (e) {
      throw Exception('포인트 트랜잭션 처리 중 오류가 발생했습니다: $e');
    }
  }

  // 포인트 구매 트랜잭션
  Future<void> processPurchase({
    required String userId,
    required int points,
    required int bonusPoints,
    required int price,
    required String productId,
    Map<String, dynamic> metadata = const {},
  }) async {
    await processTransaction(
      PointTransaction(
        userId: userId,
        points: points,
        bonusPoints: bonusPoints,
        type: PointTransactionType.purchase,
        reason: '포인트 구매',
        metadata: {
          'price': price,
          'productId': productId,
          'paymentMethod': 'IAP',
        },
      ),
    );
  }

  // 리워드 포인트 지급
  Future<void> processReward({
    required String userId,
    required int points,
    required String reason,
    Map<String, dynamic> metadata = const {},
  }) async {
    await processTransaction(
      PointTransaction(
        userId: userId,
        points: points,
        type: PointTransactionType.reward,
        reason: reason,
        metadata: metadata,
      ),
    );
  }

  // 포인트 사용
  Future<void> processUsage({
    required String userId,
    required int points,
    required String reason,
    Map<String, dynamic> metadata = const {},
  }) async {
    await processTransaction(
      PointTransaction(
        userId: userId,
        points: -points, // 음수로 변환
        type: PointTransactionType.usage,
        reason: reason,
        metadata: metadata,
      ),
    );
  }

  // 거래 내역 조회
  Future<List<Map<String, dynamic>>> getTransactionHistory(String userId,
      {PointTransactionType? type}) async {
    try {
      var query = _firestore
          .collection('pointTransactions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true);

      if (type != null) {
        query = query.where('type', isEqualTo: type.toString());
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('거래 내역 조회 중 오류가 발생했습니다: $e');
    }
  }
}
