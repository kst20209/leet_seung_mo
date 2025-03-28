import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/auth_repository.dart';
import '../utils/firebase_service.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
  guest,
}

class AppAuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthRepository _authRepository = AuthRepository(FirebaseService());

  User? _user;
  AuthStatus _status = AuthStatus.uninitialized;
  String? _error;

  // Getters
  User? get user => _user;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Constructor
  AppAuthProvider() {
    _user = _auth.currentUser;
    _status =
        _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;

    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _status =
          user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
    });

    notifyListeners();
  }

  // 게스트 모드 진입 메서드 추가
  void enterGuestMode() {
    _status = AuthStatus.guest;
    _user = null;
    _error = null;
    notifyListeners();
  }

  // 게스트 모드 종료 메서드 추가
  void exitGuestMode() {
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  bool get isGuest => _status == AuthStatus.guest;

  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      final userCredential =
          await _authRepository.signUpWithEmail(email, password);
      _user = userCredential.user;
      _status = AuthStatus.authenticated;
      _error = null;
      notifyListeners();

      if (_user != null && _onLoginSuccess != null) {
        _onLoginSuccess!(_user!);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      final userCredential =
          await _authRepository.signInWithEmail(email, password);
      _user = userCredential.user;
      _status = AuthStatus.authenticated;
      _error = null;
      notifyListeners();

      if (_user != null && _onLoginSuccess != null) {
        _onLoginSuccess!(_user!);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Phone verification methods
  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
          onVerificationCompleted(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _error = _getErrorMessage(e);
          onError(_error!);
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
        forceResendingToken: null,
      );
    } catch (e) {
      _error = e.toString();
      onError(_error!);
      notifyListeners();
    }
  }

  Future<bool> verifyCode(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _signInWithCredential(credential);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;
      _status = AuthStatus.authenticated;
      _error = null;
      notifyListeners();

      if (_user != null && _onLoginSuccess != null) {
        _onLoginSuccess!(_user!); // async/await 제거
      }
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      throw _error!;
    }
  }

  // 휴대폰 번호 추가
  Future<bool> linkPhoneNumber(PhoneAuthCredential credential) async {
    try {
      if (_user == null) {
        _error = "로그인이 필요합니다";
        notifyListeners();
        return false;
      }

      final authResult = await _user!.linkWithCredential(credential);
      _user = authResult.user;
      _error = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> updatePhoneNumber(PhoneAuthCredential credential) async {
    try {
      await _auth.currentUser?.updatePhoneNumber(credential);
      _error = null;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e);
      notifyListeners();
      throw _error!;
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw _error!;
    }
  }

  Future<void> deleteAccount() async {
    try {
      // AuthRepository 생성 및 deleteAccount 메서드 호출
      final authRepository = AuthRepository(FirebaseService());
      await authRepository.deleteAccount();

      // 성공 후 사용자 상태 업데이트
      _user = null;
      _status = AuthStatus.unauthenticated;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw _error!;
    }
  }

  Function(User)? _onLoginSuccess;

  void setLoginSuccessCallback(Function(User) callback) {
    _onLoginSuccess = callback;
  }

  void removeLoginSuccessCallback() {
    _onLoginSuccess = null;
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return '유효하지 않은 전화번호입니다.';
      case 'invalid-verification-code':
        return '유효하지 않은 인증번호입니다.';
      case 'too-many-requests':
        return '너무 많은 요청이 있었습니다. 잠시 후 다시 시도해주세요.';
      case 'user-disabled':
        return '해당 계정이 비활성화되었습니다.';
      default:
        return '오류가 발생했습니다: ${e.message}';
    }
  }

  // 이메일 유효성 검사 메서드
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

// 아이디 유효성 검사 메서드 (4~12자)
  bool isValidUsername(String username) {
    return username.length >= 4 && username.length <= 12;
  }

// 비밀번호 유효성 검사 메서드 (8자 이상)
  bool isValidPassword(String password) {
    return password.length >= 8;
  }
}
