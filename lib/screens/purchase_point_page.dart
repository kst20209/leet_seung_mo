import 'dart:async';
import 'package:flutter/material.dart';
import 'package:leet_seung_mo/utils/responsive_container.dart';
import 'package:provider/provider.dart';
import '../providers/user_data_provider.dart';
import '../utils/iap/iap_service.dart';

class PurchasePointPage extends StatefulWidget {
  const PurchasePointPage({Key? key}) : super(key: key);

  @override
  State<PurchasePointPage> createState() => _PurchasePointPageState();
}

class _PurchasePointPageState extends State<PurchasePointPage> {
  final IAPService _iapService = IAPService();
  bool _isProcessing = false;
  StreamSubscription? _purchaseResultSubscription;

  @override
  void initState() {
    super.initState();
    _initializeIAP();
    _setupPurchaseResultListener();
  }

  Future<void> _initializeIAP() async {
    try {
      _iapService.setContext(context);
      await _iapService.initialize();
    } catch (e) {
      if (mounted) {
        // SnackBar 대신 Dialog 사용
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('결제 서비스 초기화 실패'),
              content: Text('현재 포인트 구매 서비스를 이용할 수 없습니다.\n잠시 후 다시 시도해주세요.'),
              actions: [
                TextButton(
                  child: Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Dialog 닫기
                    Navigator.of(context).pop(); // PurchasePointPage 닫기
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _setupPurchaseResultListener() {
    _purchaseResultSubscription = _iapService.purchaseResultStream.listen(
      (result) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? ''),
              backgroundColor: result.success ? Colors.green : Colors.red,
            ),
          );

          setState(() => _isProcessing = false);
        }
      },
    );
  }

  // 포인트 상품 데이터
  final List<Map<String, dynamic>> pointProducts = const [
    {'points': 250, 'price': 3000, 'bonus': 0, 'productId': 'point_250'},
    {'points': 500, 'price': 4500, 'bonus': 0, 'productId': 'point_500'},
    {'points': 1000, 'price': 9000, 'bonus': 0, 'productId': 'point_1000'},
  ];

  Future<void> _processPurchase(
      BuildContext context, Map<String, dynamic> product) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      if (_iapService.isAvailable) {
        final productId = product['productId'];
        final productDetails = _iapService.products.firstWhere(
          (p) => p.id == productId,
          orElse: () => throw Exception('상품을 찾을 수 없습니다.'),
        );

        await _iapService.buyProduct(productDetails);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('구매 초기화 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _purchaseResultSubscription?.cancel();
    super.dispose();
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
    return PopScope(
      canPop: !_isProcessing, // 처리 중일 때 뒤로가기 방지
      onPopInvokedWithResult: (didPop, Object? result) {
        if (!didPop && _isProcessing) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('구매 처리 중입니다. 잠시 기다려 주세요.')),
          );
        }
      },
      child: Scaffold(
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
                  child: ResponsiveContainer(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      itemCount: pointProducts.length,
                      itemBuilder: (context, index) {
                        final product = pointProducts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            elevation: 3,
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: InkWell(
                              onTap: _isProcessing
                                  ? null
                                  : () => _showPurchaseConfirmDialog(
                                      context, product),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                child: Row(
                                  children: [
                                    // 왼쪽 포인트 표시 영역
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAF4EF),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.stars_rounded,
                                            color: Color(0xFFAF8F6F),
                                            size: 32,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${product['points']}P',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFAF8F6F),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    // 오른쪽 정보 영역
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${product['price'].toString().replaceAllMapped(
                                                  RegExp(
                                                      r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                                  (Match m) => '${m[1]},',
                                                )}원',
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (product['bonus'] > 0) ...[
                                            const SizedBox(height: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                '+${product['bonus']}P 보너스',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.green.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Colors.black26,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
