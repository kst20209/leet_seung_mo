const functions = require('firebase-functions');
const { verifyIosReceipt } = require('./iap/ios-verification');
const { verifyAndroidPurchase } = require('./iap/android-verification');

exports.verifyPurchase = functions.https.onCall(async (data, context) => {
  const { platform, receiptData, productId, signature } = data;

  console.log('Starting purchase verification:', {
    platform,
    productId,
    hasReceiptData: !!receiptData,
    hasSignature: !!signature
  });

  try {
    if (platform === 'ios') {
      const result = await verifyIosReceipt(receiptData, productId);
      console.log('iOS verification result:', result);
      return {
        isValid: result.status === 0,
        receipt: result.receipt
      };
    } else if (platform === 'android') {
      const result = await verifyAndroidPurchase(
        receiptData,
        signature,
        productId,
        process.env.ANDROID_PACKAGE_NAME
      );
      console.log('Android verification result:', result);
      return {
        isValid: result.purchaseState === 0,
        purchaseInfo: result
      };
    } else {
      throw new functions.https.HttpsError(
        'invalid-argument',
        '지원하지 않는 플랫폼입니다.'
      );
    }
  } catch (error) {
    console.error('Purchase verification failed:', error);
    throw new functions.https.HttpsError('internal', '구매 검증 실패: ' + error.message);
  }
});