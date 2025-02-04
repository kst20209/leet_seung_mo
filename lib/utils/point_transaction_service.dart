import 'package:cloud_firestore/cloud_firestore.dart';

enum PointTransactionType {
  purchase,
  reward,
  usage,
  refund,
  adjustment,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
}

class PointTransaction {
  final String userId;
  final int points;
  final int? bonusPoints;
  final PointTransactionType type;
  final String reason;
  final Map<String, dynamic> metadata;
  final TransactionStatus status;

  PointTransaction({
    required this.userId,
    required this.points,
    this.bonusPoints = 0,
    required this.type,
    required this.reason,
    this.metadata = const {},
    this.status = TransactionStatus.pending,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'points': points,
        'bonusPoints': bonusPoints,
        'type': type.toString(),
        'reason': reason,
        'metadata': metadata,
        'status': status.toString(),
      };
}

class PointTransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 포인트 구매 처리
  Future<void> processPurchase({
    required String userId,
    required int points,
    required int bonusPoints,
    required int price,
    required String productId,
    Map<String, dynamic> metadata = const {},
  }) async {
    final String transactionId =
        _firestore.collection('pointTransactions').doc().id;
    final totalPoints = points + bonusPoints;

    await _firestore.runTransaction((transaction) async {
      // 1. 사용자 문서 확인
      final userDoc =
          await transaction.get(_firestore.collection('users').doc(userId));

      if (!userDoc.exists) {
        throw Exception('사용자를 찾을 수 없습니다.');
      }

      final currentPoints = userDoc.data()?['currentPoints'] ?? 0;
      final newBalance = currentPoints + totalPoints;

      // 2. pointTransactions 컬렉션에 저장
      final transactionData = {
        'userId': userId,
        'points': points,
        'bonusPoints': bonusPoints,
        'type': PointTransactionType.purchase.toString(),
        'reason': '포인트 구매',
        'metadata': {
          ...metadata,
          'price': price,
          'productId': productId,
          'paymentMethod': 'IAP',
        },
        'status': TransactionStatus.completed.toString(),
        'transactionId': transactionId,
        'createdAt': FieldValue.serverTimestamp(),
        'completedAt': FieldValue.serverTimestamp(),
      };

      transaction.set(
          _firestore.collection('pointTransactions').doc(transactionId),
          transactionData);

      // 3. 사용자의 transactions 서브컬렉션에 저장
      transaction.set(
          _firestore
              .collection('users')
              .doc(userId)
              .collection('transactions')
              .doc(transactionId),
          transactionData);

      // 4. 사용자 문서 업데이트
      transaction.update(userDoc.reference, {
        'currentPoints': newBalance,
        'totalPurchasedPoints': FieldValue.increment(totalPoints),
        'totalSpentAmount': FieldValue.increment(price),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    });
  }

  // 포인트 사용
  Future<void> processUsage({
    required String userId,
    required int points,
    required String reason,
    Map<String, dynamic> metadata = const {},
  }) async {
    final String transactionId =
        _firestore.collection('pointTransactions').doc().id;

    await _firestore.runTransaction((transaction) async {
      // 1. 사용자 문서 확인 및 포인트 검증
      final userDoc =
          await transaction.get(_firestore.collection('users').doc(userId));

      if (!userDoc.exists) {
        throw Exception('사용자를 찾을 수 없습니다.');
      }

      final currentPoints = userDoc.data()?['currentPoints'] ?? 0;
      if (currentPoints < points) {
        throw Exception('포인트가 부족합니다.');
      }

      final newBalance = currentPoints - points;

      // 2. pointTransactions 컬렉션에 저장
      final transactionData = {
        'userId': userId,
        'points': -points,
        'type': PointTransactionType.usage.toString(),
        'reason': reason,
        'metadata': metadata,
        'status': TransactionStatus.completed.toString(),
        'transactionId': transactionId,
        'createdAt': FieldValue.serverTimestamp(),
        'completedAt': FieldValue.serverTimestamp(),
      };

      transaction.set(
          _firestore.collection('pointTransactions').doc(transactionId),
          transactionData);

      // 3. 사용자의 transactions 서브컬렉션에 저장
      transaction.set(
          _firestore
              .collection('users')
              .doc(userId)
              .collection('transactions')
              .doc(transactionId),
          transactionData);

      // 4. 사용자 문서 업데이트
      transaction.update(userDoc.reference, {
        'currentPoints': newBalance,
        'totalUsedPoints': FieldValue.increment(points),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    });
  }

// 리워드 포인트 지급
  Future<void> processReward({
    required String userId,
    required int points,
    required String reason,
    Map<String, dynamic> metadata = const {},
  }) async {
    final String transactionId =
        _firestore.collection('pointTransactions').doc().id;

    await _firestore.runTransaction((transaction) async {
      // 1. 사용자 문서 확인
      final userDoc =
          await transaction.get(_firestore.collection('users').doc(userId));

      if (!userDoc.exists) {
        throw Exception('사용자를 찾을 수 없습니다.');
      }

      final currentPoints = userDoc.data()?['currentPoints'] ?? 0;
      final newBalance = currentPoints + points;

      // 2. pointTransactions 컬렉션에 저장
      final transactionData = {
        'userId': userId,
        'points': points,
        'type': PointTransactionType.reward.toString(),
        'reason': reason,
        'metadata': {
          ...metadata,
          'rewardType': metadata['rewardType'] ?? 'general',
          'rewardId': metadata['rewardId'],
          'eventId': metadata['eventId'],
        },
        'status': TransactionStatus.completed.toString(),
        'transactionId': transactionId,
        'createdAt': FieldValue.serverTimestamp(),
        'completedAt': FieldValue.serverTimestamp(),
      };

      transaction.set(
          _firestore.collection('pointTransactions').doc(transactionId),
          transactionData);

      // 3. 사용자의 transactions 서브컬렉션에 저장
      transaction.set(
          _firestore
              .collection('users')
              .doc(userId)
              .collection('transactions')
              .doc(transactionId),
          transactionData);

      // 4. 사용자 문서 업데이트
      transaction.update(userDoc.reference, {
        'currentPoints': newBalance,
        'totalRewardPoints': FieldValue.increment(points),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> processIAPPurchase({
    required String userId,
    required int points,
    required int price,
    required Map<String, dynamic> metadata,
  }) async {
    return processPurchase(
      userId: userId,
      points: points,
      bonusPoints: 0,
      price: price,
      productId: metadata['productId'],
      metadata: {
        ...metadata,
        'type': 'iap_purchase',
      },
    );
  }

  // 특정 사용자의 트랜잭션 내역 조회
  Future<List<Map<String, dynamic>>> getUserTransactionHistory(
    String userId, {
    PointTransactionType? type,
    bool includeAllStatuses = false,
    int? limit,
  }) async {
    try {
      var query = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('createdAt', descending: true);

      if (!includeAllStatuses) {
        query = query.where('status',
            isEqualTo: TransactionStatus.completed.toString());
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.toString());
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('거래 내역 조회 중 오류가 발생했습니다: $e');
    }
  }

  // 전체 트랜잭션 내역 조회 (관리자용)
  Future<List<Map<String, dynamic>>> getAllTransactions({
    PointTransactionType? type,
    bool includeAllStatuses = false,
    int? limit,
    String? lastTransactionId,
  }) async {
    try {
      var query = _firestore
          .collection('pointTransactions')
          .orderBy('createdAt', descending: true);

      if (!includeAllStatuses) {
        query = query.where('status',
            isEqualTo: TransactionStatus.completed.toString());
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.toString());
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (lastTransactionId != null) {
        final lastDoc = await _firestore
            .collection('pointTransactions')
            .doc(lastTransactionId)
            .get();
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('거래 내역 조회 중 오류가 발생했습니다: $e');
    }
  }
}
