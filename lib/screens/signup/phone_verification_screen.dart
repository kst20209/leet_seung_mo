import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leet_seung_mo/utils/responsive_container.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import '../../main.dart';
import '../../widgets/build_text_field.dart';
import '../../utils/firebase_service.dart';
import '../../utils/auth_repository.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final Future<void> Function() onNext;

  PhoneVerificationScreen({required this.onNext});

  @override
  _PhoneVerificationScreenState createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository(FirebaseService());

  String? _phoneError;
  String? _codeError;
  bool _isCodeSent = false;
  String? _verificationId;
  Timer? _timer;
  int _timeLeft = 60; // 1분으로 유지

  // 약관 및 개인정보처리방침 URL
  final String _policyUrl = 'https://leetoreum.com/policy';
  final String _privacyUrl = 'https://leetoreum.com/privacy';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 60;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _verificationId = null;
          _isCodeSent = false;
          _codeError = '인증 시간이 만료되었습니다.';
        });
        _formKey.currentState?.validate();
      }
    });
  }

  String get _formatTime {
    return '${(_timeLeft ~/ 60).toString().padLeft(2, '0')}:${(_timeLeft % 60).toString().padLeft(2, '0')}';
  }

  // URL 열기 함수
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('URL을 열 수 없습니다')),
      );
    }
  }

  Future<void> _sendVerificationCode() async {
    setState(() {
      _phoneError = null;
    });

    try {
      String phoneNumber = _phoneController.text.trim();
      if (phoneNumber.isEmpty) {
        setState(() {
          _phoneError = '휴대폰 번호를 입력해주세요';
        });
        _formKey.currentState?.validate();
        return;
      }

      if (!phoneNumber.startsWith('+82')) {
        phoneNumber = '+82' + phoneNumber.substring(1);
      }

      await _authRepository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onVerificationCompleted: _onVerificationCompleted,
        onVerificationFailed: _onVerificationFailed,
        onCodeSent: _onCodeSent,
        onCodeAutoRetrievalTimeout: _onCodeAutoRetrievalTimeout,
      );
    } catch (e) {
      setState(() {
        _phoneError = e.toString();
      });
      _formKey.currentState?.validate();
    }
  }

  void _onVerificationCompleted(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _authRepository.signUpWithPhone(credential);
      _timer?.cancel();

      // 새로운 사용자인 경우에만 다음 회원가입 단계로 진행
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await widget.onNext();
      } else {
        // 기존 사용자는 바로 메인 화면으로 이동
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      setState(() {
        _codeError = '인증에 실패했습니다. 다시 시도해주세요.';
      });
      _formKey.currentState?.validate();
    }
  }

  void _onVerificationFailed(FirebaseAuthException e) {
    setState(() {
      _phoneError = _authRepository.getPhoneVerificationErrorMessage(e);
    });
    _formKey.currentState?.validate();
  }

  void _onCodeSent(String verificationId, int? resendToken) {
    setState(() {
      _verificationId = verificationId;
      _isCodeSent = true;
    });
    _startTimer();
  }

  void _onCodeAutoRetrievalTimeout(String verificationId) {
    if (mounted && !_isCodeSent) {
      setState(() {
        _verificationId = verificationId;
      });
    }
  }

  Future<void> _verifyCode() async {
    setState(() {
      _codeError = null;
    });

    try {
      if (_verificationId == null || _codeController.text.isEmpty) {
        setState(() {
          _codeError = '인증번호를 입력해주세요';
        });
        _formKey.currentState?.validate();
        return;
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _codeController.text,
      );

      await _authRepository.signUpWithPhone(credential);
      _timer?.cancel();
      await widget.onNext();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _codeError = _authRepository.getPhoneVerificationErrorMessage(e);
      });
      _formKey.currentState?.validate();
    } catch (e) {
      setState(() {
        _codeError = e is Exception ? e.toString() : '인증에 실패했습니다';
      });
      _formKey.currentState?.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('휴대폰 인증'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ResponsiveContainer(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BuildTextFieldWithButton(
                          context: context,
                          controller: _phoneController,
                          label: '휴대폰 번호',
                          buttonText: '인증번호 전송',
                          onPressed: _sendVerificationCode,
                          validator: (value) => _phoneError,
                          keyboardType: TextInputType.phone,
                        ),
                        if (_isCodeSent) ...[
                          SizedBox(height: 16),
                          BuildTextFieldWithButton(
                            context: context,
                            controller: _codeController,
                            label: '인증번호 ($_formatTime)',
                            buttonText: '확인',
                            onPressed: _verifyCode,
                            validator: (value) => _codeError,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                  child: ElevatedButton(
                    child: Text('다음', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: null,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: '휴대폰 인증과 함께 ',
                      ),
                      TextSpan(
                        text: '이용약관',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _launchUrl(_policyUrl),
                      ),
                      TextSpan(
                        text: ' 및 ',
                      ),
                      TextSpan(
                        text: '개인정보처리방침',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _launchUrl(_privacyUrl),
                      ),
                      TextSpan(
                        text: '에 동의하는 것으로 간주합니다.',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
