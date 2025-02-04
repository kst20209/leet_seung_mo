import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../point_transaction_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();
  late BuildContext _context;
  final bool _debugMode = true;

  void setContext(BuildContext context) {
    _context = context;
  }

  void _debugLog(String message) {
    if (_debugMode) {
      print('🛍️ IAP: $message'); // 구분하기 쉽게 이모지 사용
    }
  }

  final InAppPurchase _iap = InAppPurchase.instance;
  final PointTransactionService _pointTransactionService =
      PointTransactionService();

  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // userId 가져오기
  String? get _userId => _context.read<AppAuthProvider>().user?.uid;

  // 디버깅을 위한 로그 추가
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    print('Purchase Status: ${purchaseDetails.status}');
    print('Product ID: ${purchaseDetails.productID}');

    if (purchaseDetails.status == PurchaseStatus.purchased) {
      final userId = _userId;
      if (userId == null) {
        print('Error: User not logged in');
        return;
      }

      try {
        final points = _pointMapping[purchaseDetails.productID] ?? 0;
        print('Processing purchase - Points: $points');

        await _pointTransactionService.processIAPPurchase(
          userId: userId,
          points: points,
          price: _getPrice(purchaseDetails.productID),
          metadata: {
            'productId': purchaseDetails.productID,
            'transactionId': purchaseDetails.purchaseID ?? '',
            'receipt': purchaseDetails.verificationData.serverVerificationData,
            'platform': 'ios',
          },
        );

        print('Purchase processed successfully');

        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
          print('Purchase completed');
        }
      } catch (e) {
        print('Error processing purchase: $e');
      }
    }
  }

  // 상품 ID 정의
  static const Set<String> _productIds = {
    'Point250',
    'Point500',
    'Point1000',
  };

  // 가격 매핑 추가
  static const Map<String, int> _priceMapping = {
    'Point250': 3000,
    'Point500': 4500,
    'Point1000': 9000,
  };

  int _getPrice(String productId) {
    return _priceMapping[productId] ?? 0;
  }

  // 포인트 매핑
  static const Map<String, int> _pointMapping = {
    'Point250': 250,
    'Point500': 500,
    'Point1000': 1000,
  };

  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;

  Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) return;

    await loadProducts();
    _setupPurchaseStream();
  }

  Future<void> loadProducts() async {
    _debugLog('Loading products...');
    _debugLog('Product IDs to load: $_productIds');

    final ProductDetailsResponse response =
        await _iap.queryProductDetails(_productIds);

    if (response.error != null) {
      _debugLog('❌ Error loading products: ${response.error}');
      return;
    }

    _products = response.productDetails;
    _debugLog('✅ Loaded ${_products.length} products:');
    _products.forEach((product) {
      _debugLog('''
      ID: ${product.id}
      Title: ${product.title}
      Description: ${product.description}
      Price: ${product.price}
      ''');
    });
  }

  void _setupPurchaseStream() {
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdate,
      onError: _handleError,
    );
  }

  Future<void> _handlePurchaseUpdate(
      List<PurchaseDetails> purchaseDetails) async {
    for (var purchase in purchaseDetails) {
      await _handlePurchase(purchase);
    }
  }

  void _handleError(IAPError error) {
    print('Error: ${error.message}');
    // 에러 처리 로직 추가 필요
  }

  Future<bool> buyProduct(ProductDetails product) async {
    _debugLog('Starting purchase for product: ${product.id}');

    if (!_isAvailable) {
      _debugLog('❌ Store not available');
      return false;
    }

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );
      _debugLog('Initiating purchase with params: $purchaseParam');

      final bool success = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
      );

      _debugLog(
          success ? '✅ Purchase initiated' : '❌ Purchase failed to initiate');
      return success;
    } catch (e) {
      _debugLog('❌ Error making purchase: $e');
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
