const axios = require('axios');

exports.verifyIosReceipt = async (receiptData, productId) => {
  // 프로덕션/샌드박스 URL
  const productionUrl = 'https://buy.itunes.apple.com/verifyReceipt';
  const sandboxUrl = 'https://sandbox.itunes.apple.com/verifyReceipt';
  
  const verifyWithUrl = async (url) => {
    try {
      const response = await axios.post(url, {
        'receipt-data': receiptData,
        'password': process.env.APPSTORE_SECRET // 환경변수에서 로드
      });
      
      return response.data;
    } catch (error) {
      console.error(`Verification failed with ${url}:`, error);
      throw error;
    }
  };

  try {
    // 먼저 프로덕션으로 시도
    const result = await verifyWithUrl(productionUrl);
    
    // 21007 에러는 샌드박스 영수증을 의미
    if (result.status === 21007) {
      return await verifyWithUrl(sandboxUrl);
    }
    
    return result;
  } catch (error) {
    console.error('iOS verification failed:', error);
    throw error;
  }
};