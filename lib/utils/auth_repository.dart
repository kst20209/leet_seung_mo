import 'firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseService _firebaseService;

  AuthRepository(this._firebaseService);

  Future<UserCredential> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseService
          .createUserWithEmailAndPassword(email, password);
      await _firebaseService.sendEmailVerification();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleSignUpError(e);
    }
  }

  Future<void> signOut() async {
    await _firebaseService.signOut();
  }

  String _handleSignUpError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return '비밀번호가 너무 약합니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일 주소입니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일 주소입니다.';
      default:
        return '회원가입 중 오류가 발생했습니다: ${e.message}';
    }
  }
}
