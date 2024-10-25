import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/firebase_service.dart';
import '../../utils/user_repository.dart';
import 'signup/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final UserRepository _userRepository = UserRepository(FirebaseService());

  String? _verificationId;
  bool _codeSent = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // 상태바 스타일 설정
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _verifyPhone() async {
    setState(() {
      _error = null;
    });

    if (_phoneController.text.isEmpty) {
      setState(() {
        _error = '전화번호를 입력해주세요';
      });
      return;
    }

    String phoneNumber = _phoneController.text;
    if (!phoneNumber.startsWith('+82')) {
      phoneNumber = '+82' + phoneNumber.substring(1);
    }

    try {
      await _userRepository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onVerificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        onVerificationFailed: (FirebaseAuthException e) {
          setState(() {
            _error = _userRepository.getPhoneVerificationErrorMessage(e);
          });
        },
        onCodeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
          });
        },
        onCodeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _showSuccessMessage(user);
        widget.onLoginSuccess();
      }
    } catch (e) {
      setState(() {
        _error = '로그인에 실패했습니다: ${e.toString()}';
      });
    }
  }

  Future<void> _verifyCode() async {
    if (_verificationId == null || _codeController.text.isEmpty) {
      setState(() {
        _error = '인증번호를 입력해주세요';
      });
      return;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _codeController.text,
      );
      await _signInWithCredential(credential);
    } catch (e) {
      setState(() {
        _error = '인증에 실패했습니다: ${e.toString()}';
      });
    }
  }

  void _showSuccessMessage(User user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user.phoneNumber} 님으로 로그인되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '리승모',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: '휴대폰 번호',
                    border: OutlineInputBorder(),
                    enabled: !_codeSent,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),
                if (_codeSent)
                  TextFormField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: '인증번호',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                SizedBox(height: 16),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _codeSent ? _verifyCode : _verifyPhone,
                  child: Text(_codeSent ? '로그인' : '인증번호 받기'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  child: Text('회원가입'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
