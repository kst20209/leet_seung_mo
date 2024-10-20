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

  void _sendVerificationCode() {
    if (_formKey.currentState!.validate()) {
      String phoneNumber = _phoneController.text;
      if (!phoneNumber.startsWith('+82')) {
        phoneNumber = '+82' + phoneNumber.substring(1);
      }

      FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Automatically sign in the user
          await FirebaseAuth.instance.signInWithCredential(credential);
          await _userRepository.updatePhoneVerificationStatus(
              true, _phoneController.text);
          widget.onNext();
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _phoneError = _userRepository.getPhoneVerificationErrorMessage(e);
          });
          _formKey.currentState?.validate(); // Trigger validation to show error
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isCodeSent = true;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    }
  }

  void _verifyCode() {
    if (_formKey.currentState!.validate()) {
      if (_verificationId != null) {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: _codeController.text,
        );
        FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((userCredential) {
          _userRepository.updatePhoneVerificationStatus(
              true, _phoneController.text);
          widget.onNext();
        }).catchError((e) {
          setState(() {
            _codeError = e.message;
          });
          _formKey.currentState?.validate(); // Trigger validation to show error
        });
      }
    }
  }
}
