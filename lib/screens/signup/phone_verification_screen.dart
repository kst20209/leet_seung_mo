import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../widgets/build_text_field.dart';
import '../../utils/firebase_service.dart';
import '../../utils/user_repository.dart';

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
  final UserRepository _userRepository = UserRepository(FirebaseService());

  String? _phoneError;
  String? _codeError;
  bool _isCodeSent = false;
  String? _verificationId;
  Timer? _timer;
  int _timeLeft = 60; // 1분으로 유지

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

      bool isAvailable =
          await _userRepository.isPhoneNumberAvailable(phoneNumber);
      if (!isAvailable) {
        setState(() {
          _phoneError = '이미 사용 중인 전화번호입니다';
        });
        _formKey.currentState?.validate();
        return;
      }

      await _userRepository.verifyPhoneNumber(
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
      await _userRepository.linkPhoneCredential(credential);
      _timer?.cancel();
      await widget.onNext();
    } catch (e) {
      setState(() {
        _codeError = '인증에 실패했습니다. 다시 시도해주세요.';
      });
      _formKey.currentState?.validate();
    }
  }

  void _onVerificationFailed(FirebaseAuthException e) {
    setState(() {
      _phoneError = _userRepository.getPhoneVerificationErrorMessage(e);
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

      await _userRepository.linkPhoneCredential(credential);
      _timer?.cancel();
      await widget.onNext();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _codeError = _userRepository.getPhoneVerificationErrorMessage(e);
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
      ),
      body: Column(
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
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              child: Text('다음', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _isCodeSent ? widget.onNext : null,
            ),
          ),
        ],
      ),
    );
  }
}
