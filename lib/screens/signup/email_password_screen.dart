import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leet_seung_mo/utils/firebase_service.dart';
import 'package:leet_seung_mo/utils/user_repository.dart';
import '../../widgets/build_text_field.dart';

class EmailPasswordScreen extends StatefulWidget {
  final Future<void> Function() onNext;

  EmailPasswordScreen({required this.onNext});

  @override
  _EmailPasswordScreenState createState() => _EmailPasswordScreenState();
}

class _EmailPasswordScreenState extends State<EmailPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final UserRepository _userRepository = UserRepository(FirebaseService());

  String? _emailError;

  bool isPasswordStrong(String password) {
    if (password.length < 6 || password.length > 15) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  Future<void> _createAccount() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        UserCredential userCredential = await _userRepository.createAccount(
          _emailController.text,
          _passwordController.text,
        );
        if (userCredential.user != null) {
          await widget.onNext();
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _emailError = _userRepository.getErrorMessage(e);
        });
        _formKey.currentState
            ?.validate(); // Trigger validation again to show error immediately
      } catch (e) {
        setState(() {
          _emailError = '계정을 생성하는 동안 오류가 발생했습니다.';
        });
        _formKey.currentState
            ?.validate(); // Trigger validation again to show error immediately
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이메일/비밀번호 입력'),
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
                      BuildTextField(
                        context: context,
                        controller: _emailController,
                        label: '이메일',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이메일을 입력해주세요';
                          }
                          if (_emailError != null) {
                            final error = _emailError;
                            _emailError =
                                null; // Clear the error after showing it once
                            return error;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      BuildTextField(
                        context: context,
                        controller: _passwordController,
                        label: '비밀번호',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 입력해주세요';
                          }
                          if (!isPasswordStrong(value)) {
                            return '비밀번호는 6-15자이며, 숫자와 특수문자를 포함해야 합니다';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      BuildTextField(
                        context: context,
                        controller: _confirmPasswordController,
                        label: '비밀번호 확인',
                        obscureText: true,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return '비밀번호가 일치하지 않습니다';
                          }
                          return null;
                        },
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
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _createAccount),
          ),
        ],
      ),
    );
  }
}
