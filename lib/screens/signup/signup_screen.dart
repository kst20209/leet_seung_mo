import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'build_terms_page.dart';
import 'email_password_screen.dart';
import 'phone_verification_screen.dart';
import 'nickname_screen.dart';
import 'build_thankyou_page.dart';
import '../../utils/firebase_service.dart';
import '../../utils/user_repository.dart';
import '../../utils/data_manager.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final PageController _pageController = PageController();
  late final UserRepository _userRepository;
  int _currentPage = 0;
  bool _agreedToTerms = false;
  String? _email;
  String? _password;
  String? _phoneNumber;
  String? _nickname;
  String? _verificationId;
  User? _currentUser;

  String? _emailError;
  String? _passwordError;
  String? _phoneError;
  String? _nicknameError;

  @override
  void initState() {
    super.initState();
    final firebaseService = FirebaseService();
    _userRepository = UserRepository(firebaseService);
    DataManager().initialize(_userRepository);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          BuildTermsPage(
            agreedToTerms: _agreedToTerms,
            onAgreedToTermsChanged: (value) {
              setState(() {
                _agreedToTerms = value;
              });
            },
            onNextPressed: () {
              if (_agreedToTerms) {
                _goToNextPage();
              }
            },
          ),
          EmailPasswordScreen(
            onNext: _setEmailAndPassword,
          ),
          PhoneVerificationScreen(
            onSendCode: _sendVerificationCode,
            onVerifyCode: _verifyCode,
            onNext: _setPhoneNumber,
          ),
          NicknameScreen(onNext: _setNickname),
          BuildThankYouPage(
            onStartPressed: () {
              // TODO: Navigate to the main screen
              print('Navigate to main screen');
            },
          ),
        ],
      ),
    );
  }

  void _goToNextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
    }
  }

  Future<String?> _setEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential =
          await _userRepository.createAccount(email, password);
      _currentUser = userCredential.user;
      _email = email;
      _password = password;
      _goToNextPage();
      return null;
    } on FirebaseAuthException catch (e) {
      return _userRepository.getErrorMessage(e);
    } catch (e) {
      return '계정 생성 중 오류가 발생했습니다. 다시 시도해 주세요.';
    }
  }

  void _sendVerificationCode(String phoneNumber) async {
    // Implement Firebase phone verification logic here
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void _verifyCode(String smsCode) async {
    if (_verificationId != null) {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      try {
        await FirebaseAuth.instance.signInWithCredential(credential);
        _goToNextPage();
      } catch (e) {
        print("Error verifying SMS code: $e");
      }
    }
  }

  void _setPhoneNumber(String phoneNumber) {
    setState(() {
      _phoneNumber = phoneNumber;
      _phoneError = null;
    });
    _goToNextPage();
  }

  void _setNickname(String nickname) {
    setState(() {
      _nickname = nickname;
      _nicknameError = null;
    });
    _finishSignUp();
  }

  void _finishSignUp() async {
    try {
      if (_currentUser == null) {
        throw Exception('User not created');
      }
      await _userRepository.addPhoneNumber(
          _currentUser!.uid, _phoneNumber!, _nickname!);
      _goToNextPage(); // Go to Thank You page
    } catch (e) {
      setState(() {
        _nicknameError = '회원가입을 완료할 수 없습니다. 다시 시도해 주세요.';
      });
    }
  }
}
