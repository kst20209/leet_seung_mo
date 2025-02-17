import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';

class ReceiptVerificationService {
  // iOS/Android 플랫폼별 검증
  Future<bool> verifyPurchase(PurchaseDetails purchase) async {
    if (Platform.isIOS) {
      return _verifyIosPurchase(purchase);
    } else {
      return _verifyAndroidPurchase(purchase);
    }
  }
}

Future<bool> _verifyIosPurchase(PurchaseDetails purchase) async {
  try {
    // 앱스토어 영수증 데이터
    final receiptData = purchase.verificationData.serverVerificationData;

    // Firebase Functions를 통해 검증 (샌드박스/프로덕션 환경 모두 처리)
    final result = await FirebaseFunctions.instance
        .httpsCallable('verifyIosReceipt')
        .call({
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
        .httpsCallable('verifyAndroidPurchase')
        .call({
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
