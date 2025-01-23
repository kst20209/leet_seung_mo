import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive_container.dart';
import '../../widgets/build_text_field.dart';
import 'dart:async';

class NewPhoneScreen extends StatefulWidget {
  const NewPhoneScreen({Key? key}) : super(key: key);

  @override
  _NewPhoneScreenState createState() => _NewPhoneScreenState();
}

class _NewPhoneScreenState extends State<NewPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String? _verificationId;
  bool _codeSent = false;
  String? _error;
  bool _isVerifying = false;
  Timer? _timer;
  int _timeLeft = 60;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
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
          _codeSent = false;
          _error = '인증 시간이 만료되었습니다. 다시 시도해주세요.';
        });
      }
    });
  }

  String get _formatTime {
    int minutes = _timeLeft ~/ 60;
    int seconds = _timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _verifyNewPhone() async {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      String phoneNumber = _phoneController.text;
      if (phoneNumber.isEmpty) {
        setState(() {
          _error = '전화번호를 입력해주세요';
        });
        return;
      }

      if (!phoneNumber.startsWith('+82')) {
        phoneNumber = '+82' + phoneNumber.substring(1);
      }

      final authProvider = context.read<AppAuthProvider>();

      // 현재 전화번호와 동일한지 확인
      if (authProvider.user?.phoneNumber == phoneNumber) {
        setState(() {
          _error = '현재 사용 중인 전화번호입니다';
        });
        return;
      }

      await authProvider.verifyPhone(
        phoneNumber: phoneNumber,
        onVerificationCompleted: (credential) async {
          // 자동 인증 완료 시 처리
          await _updatePhoneNumber(credential);
        },
        onCodeSent: (verificationId) {
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _error = null;
          });
          _startTimer();
        },
        onError: (error) {
          setState(() {
            _error = error;
          });
        },
      );
    } finally {
      setState(() {
        _isVerifying = false;
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

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _codeController.text,
      );

      await _updatePhoneNumber(credential);
    } catch (e) {
      setState(() {
        _error = '인증번호가 올바르지 않습니다';
      });
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  Future<void> _updatePhoneNumber(PhoneAuthCredential credential) async {
    try {
      final authProvider = context.read<AppAuthProvider>();
      await authProvider.updatePhoneNumber(credential);

      // 성공 처리
      _timer?.cancel();

      // 성공 다이얼로그 표시
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('전화번호 변경 완료'),
            content: Text('전화번호가 성공적으로 변경되었습니다.\n변경된 전화번호로 다시 로그인해주세요.'),
            actions: [
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );

        // 로그아웃 후 메인 화면으로 이동
        await authProvider.signOut();
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _error = '전화번호 변경에 실패했습니다: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새 전화번호 입력'),
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
                    '새로운 전화번호를 입력해주세요',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  BuildTextFieldWithButton(
                    context: context,
                    controller: _phoneController,
                    label: '새 전화번호',
                    buttonText: '인증번호 받기',
                    onPressed: _isVerifying ? () {} : _verifyNewPhone,
                    keyboardType: TextInputType.phone,
                    error: _error,
                  ),
                  if (_codeSent) ...[
                    SizedBox(height: 16),
                    BuildTextFieldWithButton(
                      context: context,
                      controller: _codeController,
                      label: '인증번호 ($_formatTime)',
                      buttonText: '확인',
                      onPressed: _isVerifying ? () {} : _verifyCode,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  SizedBox(height: 16),
                  Text(
                    '* 새로운 전화번호로 인증번호가 전송됩니다.\n* 전화번호 변경 시 재로그인이 필요합니다.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
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
