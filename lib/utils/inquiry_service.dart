import 'package:cloud_firestore/cloud_firestore.dart';

class InquiryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitInquiry({
    required String userId,
    required String title,
    required String content,
    String? userNickname,
  }) async {
    try {
      await _firestore.collection('inquiries').add({
        'userId': userId,
        'title': title,
        'content': content,
        'userNickname': userNickname,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isDeleted': false,
      });
    } catch (e) {
      throw Exception('문의 제출 중 오류가 발생했습니다: $e');
    }
  }
}
