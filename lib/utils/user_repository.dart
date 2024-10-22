import 'firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final FirebaseService _firebaseService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> linkPhoneCredential(PhoneAuthCredential credential) async {
    final user = _firebaseService.currentUser;
    if (user != null) {
      await user.linkWithCredential(credential);
    } else {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: '현재 로그인된 사용자가 없습니다.',
      );
    }
  }

  Future<bool> isPhoneNumberAvailable(String phoneNumber) async {
    try {
      // 전화번호 형식 통일
      if (!phoneNumber.startsWith('+82')) {
        phoneNumber = '+82' + phoneNumber.substring(1);
      }

      // Firestore에서 전화번호로 등록된 사용자 확인
      final usersWithPhone = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      // Auth의 현재 사용자 확인
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser?.phoneNumber == phoneNumber) {
        return false; // 현재 사용자가 이미 이 전화번호를 사용 중
      }

      return usersWithPhone.docs.isEmpty; // docs가 비어있으면 사용 가능
    } on FirebaseException catch (e) {
      print('Error checking phone number availability: $e');
      throw Exception('전화번호 확인 중 오류가 발생했습니다.');
    }
  }

  Future<void> updatePhoneVerificationStatus(
      bool isVerified, String phoneNumber) async {
    final user = _firebaseService.currentUser;
    if (user != null) {
      await _firebaseService.updateDocument('users', user.uid, {
        'phoneNumber': phoneNumber,
        'isPhoneVerified': isVerified,
      });
    } else {
      throw Exception('No current user found');
    }
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
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('nickname', isEqualTo: nickname)
          .limit(1)
          .get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('Error checking nickname availability: $e');
      return false;
    }
  }

  Future<void> updateUserInfo(String uid, Map<String, dynamic> userInfo) async {
    await _firebaseService.updateDocument('users', uid, userInfo);
  }
}
