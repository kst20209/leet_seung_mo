import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/responsive_container.dart';
import '../../widgets/build_text_field.dart';

class DeleteAccountVerificationScreen extends StatefulWidget {
  final VoidCallback onVerificationSuccess;

  const DeleteAccountVerificationScreen({
    Key? key,
    required this.onVerificationSuccess,
  }) : super(key: key);

  @override
  _DeleteAccountVerificationScreenState createState() =>
      _DeleteAccountVerificationScreenState();
}

class _DeleteAccountVerificationScreenState
    extends State<DeleteAccountVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isVerifying = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verifyPassword() async {
    if (!_formKey.currentState!.validate() || _isVerifying) return;

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      // 현재 로그인한 사용자 정보 가져오기
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        setState(() {
          _isVerifying = false;
          _error = '사용자 정보를 찾을 수 없습니다.';
        });
        return;
      }

      // 이메일과 비밀번호로 재인증
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _passwordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      // 인증 성공 시 다음 단계로 진행
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
        widget.onVerificationSuccess();
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = '비밀번호가 올바르지 않습니다.';
          break;
        case 'too-many-requests':
          errorMessage = '너무 많은 요청이 있었습니다. 잠시 후 다시 시도해주세요.';
          break;
        case 'user-mismatch':
          errorMessage = '사용자 인증 정보가 일치하지 않습니다.';
          break;
        case 'invalid-credential':
          errorMessage = '비밀번호가 올바르지 않습니다.';
          break;
        default:
          errorMessage = '인증에 실패했습니다: ${e.message}';
      }

      if (mounted) {
        setState(() {
          _isVerifying = false;
          _error = errorMessage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _error = '인증 중 오류가 발생했습니다: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('계정 삭제 - 본인 확인'),
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
                    '계정 삭제를 위해\n비밀번호를 확인해주세요',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),

                  // 비밀번호 입력 필드
                  BuildTextField(
                    context: context,
                    controller: _passwordController,
                    label: '비밀번호',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 24),

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

                  // 확인 버튼
                  ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            '확인',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  SizedBox(height: 16),
                  Text(
                    '* 계정 삭제 시 모든 데이터가 영구적으로 삭제됩니다.\n* 이 작업은 되돌릴 수 없습니다.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
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
