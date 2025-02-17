const { google } = require('googleapis');

exports.verifyAndroidPurchase = async (purchaseData, productId, packageName) => {
  try {
    const auth = new google.auth.GoogleAuth({
      credentials: require('../../service-account.json'),
      scopes: ['https://www.googleapis.com/auth/androidpublisher']
    });

    const client = await auth.getClient();
    const androidpublisher = google.androidpublisher('v3');
    
    const response = await androidpublisher.purchases.products.get({
      auth: client,
      packageName: packageName,
      productId: productId,
      token: purchaseData
    });

    return response.data;
  } catch (error) {
    console.error('Android verification failed:', error);
    throw error;
  }
};