import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leet_seung_mo/utils/responsive_container.dart';
import '../../widgets/build_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _emailSent = false;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = '유효하지 않은 이메일 주소입니다.';
          break;
        case 'user-not-found':
          errorMessage = '해당 이메일로 등록된 계정이 없습니다.';
          break;
        case 'too-many-requests':
          errorMessage = '너무 많은 요청이 있었습니다. 잠시 후 다시 시도해주세요.';
          break;
        default:
          errorMessage = '비밀번호 재설정 이메일 전송 중 오류가 발생했습니다: ${e.message}';
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = errorMessage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = '비밀번호 재설정 중 오류가 발생했습니다: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비밀번호 찾기'),
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
                  Text(
                    '가입한 이메일 주소를 입력하시면\n비밀번호 재설정 링크를 보내드립니다',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // 이메일 입력 필드
                  BuildTextField(
                    context: context,
                    controller: _emailController,
                    label: '이메일',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이메일을 입력해주세요';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return '유효한 이메일 주소를 입력해주세요';
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
                  if (_emailSent)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green[800]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '비밀번호 재설정 이메일이 전송되었습니다.',
                                  style: TextStyle(
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '이메일에 포함된 링크를 통해 비밀번호를 재설정해주세요. 이메일이 보이지 않는 경우 스팸함을 확인해주세요.',
                            style: TextStyle(color: Colors.green[700]),
                          ),
                        ],
                      ),
                    ),

                  // 전송 버튼
                  ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
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
                            '비밀번호 재설정 이메일 보내기',
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
