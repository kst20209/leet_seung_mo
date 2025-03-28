import 'firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseService _firebaseService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthRepository(this._firebaseService);

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      // Firebase Auth를 통한 이메일/비밀번호 회원가입
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 새 사용자의 초기 데이터 생성
      if (userCredential.user != null) {
        await _firebaseService.createUserDocument(userCredential.user!.uid, {
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'currentPoints': 0,
          'purchasedProblemSets': []
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleSignUpError(e));
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleSignInError(e));
    }
  }

  // 로그인 에러 처리를 위한 메서드 추가
  String _handleSignInError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return '이메일이 존재하지 않거나, 비밀번호가 틀렸렸습니다.';
      case 'too-many-requests':
        return '너무 많은 로그인 시도가 있었습니다. 잠시 후 다시 시도해 주세요.';
      case 'invalid-email':
        return '유효하지 않은 이메일 주소입니다.';
      case 'network-request-failed':
        return '네트워크 연결에 문제가 있습니다. 인터넷 연결을 확인해 주세요.';
      default:
        return '로그인 중 오류가 발생했습니다: ${e.code}, ${e.message}';
    }
  }

  Future<UserCredential> signUpWithPhone(PhoneAuthCredential credential) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // 새로운 사용자인 경우에만 초기 데이터 생성
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firebaseService.createUserDocument(userCredential.user!.uid, {
          'phoneNumber': userCredential.user!.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'currentPoints': 0,
          'purchasedProblemSets': []
        });

        return userCredential;
      } else {
        // 기존 사용자인 경우 에러 발생
        throw FirebaseAuthException(
          code: 'existing-user',
          message: '이미 가입된 사용자입니다. 로그인을 시도해주세요.',
        );
      }
    } on FirebaseException catch (e) {
      throw Exception('${e.message}');
    }
  }

  Future<void> signOut() async {
    await _firebaseService.signOut();
  }

// 계정 삭제 함수
  Future<void> deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('로그인된 사용자가 없습니다');
      }

      final userId = user.uid;

      // 1. users 컬렉션에서 사용자 문서 삭제
      await _firebaseService.deleteDocument('users', userId);

      // 2. 문의 내역 익명화 처리
      await _anonymizeInquiries(userId);

      // 3. Firebase Authentication 계정 삭제
      await user.delete();

      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // 재인증이 필요한 경우 확인
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        throw Exception('계정 삭제를 위해 재로그인이 필요합니다');
      }
      rethrow;
    }
  }

// 사용자의 문의 내역을 익명화 처리
  Future<void> _anonymizeInquiries(String userId) async {
    final querySnapshot = await _firestore
        .collection('inquiries')
        .where('userId', isEqualTo: userId)
        .get();

    final batch = _firestore.batch();

    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {
        'userId': 'deleted_user',
        'userNickname': '탈퇴한 사용자',
        'isAnonymized': true,
      });
    }

    if (querySnapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String, int?) onCodeSent,
    required Function(String) onCodeAutoRetrievalTimeout,
  }) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }

  String getPhoneVerificationErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'credential-already-in-use':
        return '이미 등록된 전화번호입니다.';
      case 'invalid-phone-number':
        return '전화번호 형식이 올바르지 않습니다.';
      case 'too-many-requests':
        return '인증 요청이 너무 많습니다.';
      case 'quota-exceeded':
        return '인증 요청 한도를 초과했습니다.';
      case 'user-disabled':
        return '이 계정은 비활성화되었습니다.';
      case 'session-expired':
        return '인증 세션이 만료되었습니다.';
      default:
        return '전화번호 인증 중 오류가 발생했습니다: ${e.message}';
    }
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
