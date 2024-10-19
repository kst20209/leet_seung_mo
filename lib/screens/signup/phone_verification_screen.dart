import 'package:flutter/material.dart';
import '../../widgets/build_text_field.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final Function(String) onSendCode;
  final Function(String) onVerifyCode;
  final Function(String) onNext;

  PhoneVerificationScreen({
    required this.onSendCode,
    required this.onVerifyCode,
    required this.onNext,
  });

  @override
  _PhoneVerificationScreenState createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String? _phoneError;
  String? _codeError;
  bool _isCodeSent = false;

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
                          // You can add more phone number validation here
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
                        widget.onNext(_phoneController.text);
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
      widget.onSendCode(_phoneController.text);
      setState(() {
        _isCodeSent = true;
      });
    }
  }

  void _verifyCode() {
    if (_formKey.currentState!.validate()) {
      widget.onVerifyCode(_codeController.text);
    }
  }
}
