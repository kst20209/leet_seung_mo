import 'firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final FirebaseService _firebaseService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserRepository(this._firebaseService);

  // String getErrorMessage(FirebaseAuthException e) {
  //   switch (e.code) {
  //     case 'email-already-in-use':
  //       return '이미 사용 중인 이메일 주소입니다.';
  //     case 'invalid-email':
  //       return '유효하지 않은 이메일 주소입니다.';
  //     case 'operation-not-allowed':
  //       return '이 작업은 허용되지 않습니다. 관리자에게 문의해 주세요.';
  //     case 'user-disabled':
  //       return '이 계정은 비활성화되었습니다. 관리자에게 문의해 주세요.';
  //     default:
  //       return '계정 생성 중 오류가 발생했습니다: ${e.message}';
  //   }
  // }

  Future<DocumentSnapshot> getUser(String uid) async {
    return await _firebaseService.getDocument('users', uid);
  }

  Future<DocumentSnapshot> getCurrentUser() async {
    User? currentUser = _firebaseService.currentUser;
    if (currentUser != null) {
      return await getUser(currentUser.uid);
    }
    throw Exception('계정정보가 확인되지 않습니다.');
  }

  Future<Map<String, dynamic>> getUserInfo(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firebaseService.getDocument('users', uid);
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // 전화번호는 Auth에서만 가져옴
      String? phoneNumber = _firebaseService.getCurrentUserPhoneNumber();
      if (phoneNumber != null) {
        // 메모리에서만 임시로 사용
        userData = {...userData, 'phoneNumber': phoneNumber};
      }

      return userData;
    } catch (e) {
      throw Exception('사용자 정보를 가져오는 중 오류가 발생했습니다.');
    }
  }

  Future<bool> isNicknameAvailable(String nickname) async {
    try {
      AggregateQuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('nickname', isEqualTo: nickname)
          .count()
          .get();
      return snapshot.count == 0;
    } catch (e) {
      print('Error checking nickname availability: $e');
      return false;
    }
  }

  Future<void> updateUserInfo(String uid, Map<String, dynamic> userInfo) async {
    await _firebaseService.updateDocument('users', uid, userInfo);
  }
}
