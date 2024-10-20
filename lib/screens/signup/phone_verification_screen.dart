import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
                        error: _phoneError,
                        buttonText: '인증번호 전송',
                        onPressed: _sendVerificationCode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '휴대폰 번호를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      if (_isCodeSent) ...[
                        BuildTextFieldWithButton(
                          context: context,
                          controller: _codeController,
                          label: '인증번호',
                          error: _codeError,
                          buttonText: '확인',
                          onPressed: _verifyCode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '인증번호를 입력해주세요';
                            }
                            return null;
                          },
                        ),
                      ],
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
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isCodeSent
                  ? () {
                      if (_formKey.currentState!.validate()) {
                        widget.onNext();
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _sendVerificationCode() async {
    if (_formKey.currentState!.validate()) {
      String phoneNumber = _phoneController.text;
      if (!phoneNumber.startsWith('+82')) {
        phoneNumber = '+82' + phoneNumber.substring(1);
      }

      try {
        await _userRepository.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          onVerificationCompleted: _onVerificationCompleted,
          onVerificationFailed: _onVerificationFailed,
          onCodeSent: _onCodeSent,
          onCodeAutoRetrievalTimeout: _onCodeAutoRetrievalTimeout,
        );
      } catch (e) {
        print("Error sending verification code: $e");
        setState(() {
          _phoneError = "인증코드 전송 중 오류가 발생했습니다.";
        });
      }
    }
  }

  void _onVerificationCompleted(PhoneAuthCredential credential) async {
    try {
      await _linkPhoneCredential(credential);
    } catch (e) {
      print("Error in automatic verification: $e");
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
  }

  void _onCodeAutoRetrievalTimeout(String verificationId) {
    setState(() {
      _verificationId = verificationId;
    });
  }

  void _verifyCode() async {
    if (_formKey.currentState!.validate()) {
      if (_verificationId != null) {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: _codeController.text,
        );
        await _linkPhoneCredential(credential);
      }
    }
  }

  Future<void> _linkPhoneCredential(PhoneAuthCredential credential) async {
    try {
      await _userRepository.linkPhoneCredential(credential);
      await _userRepository.updatePhoneVerificationStatus(
          true, _phoneController.text);
      widget.onNext();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _codeError = _userRepository.getPhoneVerificationErrorMessage(e);
      });
      _formKey.currentState?.validate();
    } catch (e) {
      print("Error linking phone credential: $e");
      setState(() {
        _codeError = "인증 과정에서 오류가 발생했습니다.";
      });
    }
  }
}
