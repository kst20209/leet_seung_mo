import 'firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final FirebaseService _firebaseService;

  UserRepository(this._firebaseService);

  Future<UserCredential> createAccount(String email, String password) async {
    UserCredential userCredential =
        await _firebaseService.createUserWithEmailAndPassword(email, password);

    await _firebaseService.setDocument('users', userCredential.user!.uid, {
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'currentPoints': 0,
      'purchasedProblemSets': [],
      'lastSolvedProblems': [],
      'isPhoneVerified': false,
    });

    await _firebaseService.sendEmailVerification();

    return userCredential;
  }

  Future<void> addPhoneNumber(
      String uid, String phoneNumber, String nickname) async {
    await _firebaseService.setDocument(
        'users',
        uid,
        {
          'phoneNumber': phoneNumber,
          'nickname': nickname,
          'isPhoneVerified': true,
        },
        merge: true);
  }

  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return '이미 사용 중인 이메일 주소입니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일 주소입니다.';
      case 'operation-not-allowed':
        return '이 작업은 허용되지 않습니다. 관리자에게 문의해 주세요.';
      case 'user-disabled':
        return '이 계정은 비활성화되었습니다. 관리자에게 문의해 주세요.';
      default:
        return '계정 생성 중 오류가 발생했습니다: ${e.message}';
    }
  }

  Future<DocumentSnapshot> getUser(String uid) async {
    return await _firebaseService.getDocument('users', uid);
  }

  Future<DocumentSnapshot> getCurrentUser() async {
    User? currentUser = _firebaseService.currentUser;
    if (currentUser != null) {
      return await getUser(currentUser.uid);
    }
    throw Exception('No user currently signed in');
  }
}
