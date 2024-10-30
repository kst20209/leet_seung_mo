import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_data_provider.dart';
import '../providers/auth_provider.dart';
import 'package:uuid/uuid.dart';
import '../utils/point_transaction_service.dart';

class PurchasePointPage extends StatefulWidget {
  const PurchasePointPage({Key? key}) : super(key: key);

  @override
  State<PurchasePointPage> createState() => _PurchasePointPageState();
}

class _PurchasePointPageState extends State<PurchasePointPage> {
  final PointTransactionService _purchaseService = PointTransactionService();
  bool _isProcessing = false;

  // 포인트 상품 데이터
  final List<Map<String, dynamic>> pointProducts = const [
    {'points': 200, 'price': 2300, 'bonus': 0, 'productId': 'point_200'},
    {'points': 500, 'price': 5500, 'bonus': 50, 'productId': 'point_500'},
    {'points': 1000, 'price': 10900, 'bonus': 100, 'productId': 'point_1000'},
    {'points': 2000, 'price': 21000, 'bonus': 300, 'productId': 'point_2000'},
    {'points': 5000, 'price': 49900, 'bonus': 1000, 'productId': 'point_5000'},
    {
      'points': 10000,
      'price': 99000,
      'bonus': 2000,
      'productId': 'point_10000'
    },
  ];

  Future<void> _processPurchase(
      BuildContext context, Map<String, dynamic> product) async {
    if (_isProcessing) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final authProvider = context.read<AppAuthProvider>();
    final userDataProvider = context.read<UserDataProvider>();

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    final String transactionId = const Uuid().v4(); // 거래 고유 ID 생성

    try {
      // TODO: 실제 인앱 결제 처리 로직 구현
      // 임시로 바로 성공으로 처리

      // PointTransactionService를 사용하여 구매 처리
      await _purchaseService.processPurchase(
        userId: authProvider.user!.uid,
        points: product['points'],
        bonusPoints: product['bonus'],
        price: product['price'],
        productId: product['productId'],
        metadata: {
          'transactionId': transactionId,
          'platform': 'ios', // or 'android'
          // 실제 인앱 결제 시 추가될 정보들:
          // 'paymentId': payment.id,
          // 'orderId': payment.orderId,
          // 'purchaseToken': payment.purchaseToken,
        },
      );

      // UI 업데이트를 위해 UserDataProvider 새로고침
      await userDataProvider.refreshUserData(authProvider.user!.uid);

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('포인트 구매가 완료되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('구매 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showPurchaseConfirmDialog(
      BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('포인트 구매'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${product['points']}P',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFAF8F6F),
                ),
              ),
              if (product['bonus'] > 0)
                Text(
                  '+${product['bonus']}P 보너스',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                '${product['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              const Text('구매하시겠습니까?', style: TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('아니오'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                '예',
                style: TextStyle(color: Color(0xFFAF8F6F)),
              ),
              onPressed: _isProcessing
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      _processPurchase(context, product);
                    },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('포인트 충전'),
        elevation: 0,
      ),
      body: Consumer<UserDataProvider>(
        builder: (context, userDataProvider, child) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '현재 보유 포인트',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${userDataProvider.points}P',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFAF8F6F),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isProcessing) const LinearProgressIndicator(),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: pointProducts.length,
                  itemBuilder: (context, index) {
                    final product = pointProducts[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: _isProcessing
                            ? null
                            : () =>
                                _showPurchaseConfirmDialog(context, product),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${product['points']}P',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFAF8F6F),
                                ),
                              ),
                              if (product['bonus'] > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '+${product['bonus']}P',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                '${product['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
