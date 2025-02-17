import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class ReceiptVerificationService {
  static const bool _debugMode = true;

  void _debugLog(String message) {
    if (_debugMode) {
      print('🧾 Receipt Verification: $message');
    }
  }

  Future<bool> verifyPurchase(PurchaseDetails purchase) async {
    _debugLog('Starting purchase verification...');
    _debugLog('Purchase ID: ${purchase.purchaseID}');
    _debugLog('Product ID: ${purchase.productID}');
    _debugLog('Platform: ${Platform.isIOS ? 'iOS' : 'Android'}');
    if (Platform.isIOS) {
      return _verifyIosPurchase(purchase);
    } else {
      return _verifyAndroidPurchase(purchase);
    }
  }

  Future<bool> _verifyIosPurchase(PurchaseDetails purchase) async {
    try {
      // 앱스토어 영수증 데이터
      final receiptData = purchase.verificationData.serverVerificationData;

      // Firebase Functions를 통해 검증 (샌드박스/프로덕션 환경 모두 처리)
      final result = await FirebaseFunctions.instance
          .httpsCallable('verifyPurchase')
          .call({
        'platform': 'ios',
        'receiptData': receiptData,
        'productId': purchase.productID,
      });

      // 검증 결과 확인
      final verificationResult = result.data as Map<String, dynamic>;
      return verificationResult['isValid'] == true;
    } catch (e) {
      print('iOS 영수증 검증 실패: $e');
      return false;
    }
  }

  Future<bool> _verifyAndroidPurchase(PurchaseDetails purchase) async {
    try {
      // 구글 플레이 영수증 데이터
      final purchaseData = purchase.verificationData.serverVerificationData;
      final signature = purchase.verificationData.localVerificationData;

      // Firebase Functions를 통해 검증
      final result = await FirebaseFunctions.instance
          .httpsCallable('verifyPurchase')
          .call({
        'platform': 'android',
        'purchaseData': purchaseData,
        'signature': signature,
        'productId': purchase.productID,
      });

      // 검증 결과 확인
      final verificationResult = result.data as Map<String, dynamic>;
      return verificationResult['isValid'] == true;
    } catch (e) {
      print('Android 영수증 검증 실패: $e');
      return false;
    }
  }
}
