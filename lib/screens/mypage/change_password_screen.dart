import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leet_seung_mo/utils/responsive_container.dart';
import '../../widgets/build_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _success = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 현재 비밀번호 검증
  Future<bool> _verifyCurrentPassword(String currentPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        setState(() {
          _error = '로그인 정보를 찾을 수 없습니다.';
        });
        return false;
      }

      // 현재 비밀번호 검증을 위해 재인증
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'wrong-password':
            _error = '현재 비밀번호가 올바르지 않습니다.';
            break;
          case 'too-many-requests':
            _error = '너무 많은 요청이 있었습니다. 잠시 후 다시 시도해주세요.';
            break;
          case 'invalid-credential':
            _error = '비밀번호가 올바르지 않습니다.';
            break;
          default:
            _error = '인증에 실패했습니다: ${e.message}';
        }
      });
      return false;
    } catch (e) {
      setState(() {
        _error = '인증 중 오류가 발생했습니다: $e';
      });
      return false;
    }
  }

  // 새 비밀번호로 변경
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _success = false;
    });

    try {
      // 1. 현재 비밀번호 검증
      final isCurrentPasswordValid = await _verifyCurrentPassword(
        _currentPasswordController.text,
      );

      if (!isCurrentPasswordValid) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 2. 새 비밀번호 설정
      final user = FirebaseAuth.instance.currentUser;
      await user?.updatePassword(_newPasswordController.text);

      setState(() {
        _isLoading = false;
        _success = true;
        // 성공 시 입력 필드 초기화
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('비밀번호가 성공적으로 변경되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = '비밀번호 변경에 실패했습니다: $e';
      });
    }
  }

  bool isPasswordStrong(String password) {
    if (password.length < 6 || password.length > 15) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비밀번호 변경'),
        elevation: 0,
      ),
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 현재 비밀번호 입력
                  BuildTextField(
                    context: context,
                    controller: _currentPasswordController,
                    label: '현재 비밀번호',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '현재 비밀번호를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 새 비밀번호 입력
                  BuildTextField(
                    context: context,
                    controller: _newPasswordController,
                    label: '새 비밀번호',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '새 비밀번호를 입력해주세요';
                      }
                      if (!isPasswordStrong(value)) {
                        return '비밀번호는 6-15자이며, 소문자, 숫자, 특수문자를 포함해야 합니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 새 비밀번호 확인
                  BuildTextField(
                    context: context,
                    controller: _confirmPasswordController,
                    label: '새 비밀번호 확인',
                    obscureText: true,
                    validator: (value) {
                      if (value != _newPasswordController.text) {
                        return '비밀번호가 일치하지 않습니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 에러 메시지 표시
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[800]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(color: Colors.red[800]),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 성공 메시지 표시
                  if (_success)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[800]),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              '비밀번호가 성공적으로 변경되었습니다.',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 변경 버튼
                  ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            '비밀번호 변경',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
