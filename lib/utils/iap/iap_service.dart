import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../models/iap_product.dart';
import '../../providers/user_data_provider.dart';
import '../point_transaction_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'receipt_verification_service.dart';

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
  StreamController<PurchaseResult> _purchaseResultController =
      StreamController<PurchaseResult>.broadcast();
  Stream<PurchaseResult> get purchaseResultStream =>
      _purchaseResultController.stream;

  // userId 가져오기
  String? get _userId => _context.read<AppAuthProvider>().user?.uid;

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    _debugLog('Handling purchase...');
    _debugLog('Purchase Status: ${purchaseDetails.status}');
    _debugLog('Product ID: ${purchaseDetails.productID}');

    if (purchaseDetails.status == PurchaseStatus.canceled) {
      _debugLog('Purchase was canceled by user');
      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
        _debugLog('Canceled purchase completed');
      }
      _purchaseResultController.add(PurchaseResult(
        success: false,
        status: 'canceled',
        message: '결제가 취소되었습니다.',
      ));
      return;
    }

    if (purchaseDetails.status == PurchaseStatus.purchased) {
      final userId = _userId;
      if (userId == null) {
        _debugLog('❌ Error: User not logged in');
        _purchaseResultController.add(PurchaseResult(
          success: false,
          status: 'failed',
          message: '로그인이 필요합니다.',
        ));
        return;
      }

      try {
        final points = _pointMapping[purchaseDetails.productID] ?? 0;
        _debugLog('💰 Processing purchase - Points: $points');

        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }

        // PointTransactionService를 통한 포인트 처리
        await _pointTransactionService.processPurchase(
          userId: userId,
          points: points,
          bonusPoints: 0,
          price: _getPrice(purchaseDetails.productID),
          productId: purchaseDetails.productID,
          metadata: {
            'transactionId': purchaseDetails.purchaseID ?? '',
            'receipt': purchaseDetails.verificationData.serverVerificationData,
            'platform': Platform.isAndroid ? 'android' : 'ios',
            'type': 'iap_purchase',
          },
        );

        _debugLog('Details: ${purchaseDetails}');
        _debugLog(
            'Details: ${purchaseDetails.verificationData.serverVerificationData}');

        final verified =
            await ReceiptVerificationService().verifyPurchase(purchaseDetails);

        if (!verified) {
          _purchaseResultController.add(PurchaseResult(
            success: false,
            status: 'failed',
            message: '구매가 완료되었으나, 영수증 검증에 실패했습니다.',
          ));
          return;
        }

        // UI 갱신을 위한 Provider 업데이트
        if (_context.mounted) {
          await Provider.of<UserDataProvider>(_context, listen: false)
              .refreshUserData(userId);
          _debugLog('✅ User data refreshed');
        }

        // 구매 완료 처리
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
          _debugLog('🎉 Purchase completed');
        }
        _purchaseResultController.add(PurchaseResult(
          success: true,
          status: 'completed',
          message: '포인트 구매 및 영수증 검증이 완료되었습니다.',
        ));
      } catch (e) {
        _debugLog('❌ Error processing purchase: $e');
        _debugLog('Error stack trace: ${StackTrace.current}');
        _purchaseResultController.add(PurchaseResult(
          success: false,
          status: 'failed',
          message: '구매 처리 중 오류가 발생했습니다: $e',
        ));
        rethrow;
      }
    }
  }

  // 상품 ID 정의
  static const Set<String> _productIds = {
    'point_250',
    'point_500',
    'point_1000',
  };

  // 가격 매핑 추가
  static const Map<String, int> _priceMapping = {
    'point_250': 3000,
    'point_500': 4500,
    'point_1000': 9000,
  };

  int _getPrice(String productId) {
    return _priceMapping[productId] ?? 0;
  }

  // 포인트 매핑
  static const Map<String, int> _pointMapping = {
    'point_250': 250,
    'point_500': 500,
    'point_1000': 1000,
  };

  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;

  Future<void> initialize() async {
    _debugLog('Initializing IAP service...');
    _isAvailable = await _iap.isAvailable();
    _debugLog('IAP available: $_isAvailable');

    if (!_isAvailable) {
      _debugLog('❌ IAP not available');
      return;
    }

    await loadProducts();
    _setupPurchaseStream();
    _debugLog('IAP initialization complete');
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
    _debugLog('Setting up purchase stream...');
    _subscription = _iap.purchaseStream.listen(
      (purchaseDetails) {
        _debugLog('Purchase update received: ${purchaseDetails.length} items');
        _handlePurchaseUpdate(purchaseDetails);
      },
      onError: (error) {
        _debugLog('Purchase stream error: $error');
        _handleError(error);
      },
    );
    _debugLog('Purchase stream setup complete');
  }

  Future<void> _handlePurchaseUpdate(
      List<PurchaseDetails> purchaseDetails) async {
    for (var purchase in purchaseDetails) {
      await _handlePurchase(purchase);
    }
  }

  void _handleError(IAPError error) {
    String errorMessage = '결제 중 오류가 발생했습니다';

    if (error is Exception) {
      if (error.toString().contains('BillingResponse')) {
        errorMessage = '결제가 취소되었습니다';
      }
    }

    _purchaseResultController.add(PurchaseResult(
      success: false,
      status: 'failed',
      message: errorMessage,
    ));
    // 에러 처리 로직 추가 필요
  }

  Future<bool> buyProduct(ProductDetails product) async {
    _debugLog('🛍️Starting purchase for product: ${product.id}');

    // 디버깅을 위한 로그 추가
    _debugLog('Available products:');
    for (var p in _products) {
      _debugLog('- ${p.id}: ${p.title}');
    }

    if (!_isAvailable) {
      _debugLog('❌ Store not available');
      return false;
    }

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );
      _debugLog('🛍️Initiating purchase with params: $purchaseParam');
      _debugLog('🛍️Purchase params: ${purchaseParam.toString()}');
      _debugLog('🛍️Purchase parameter created for product: ${product.id}');

      final bool success = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
      );

      _debugLog(
          success ? '✅ Purchase initiated' : '❌ Purchase failed to initiate');
      return success;
    } catch (e) {
      _debugLog('❌ Error making purchase: $e');
      _debugLog('🛍️Error stack trace: ${StackTrace.current}');
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _purchaseResultController.close();
  }
}
