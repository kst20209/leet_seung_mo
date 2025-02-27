import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/auth_provider.dart';
import '../../utils/responsive_container.dart';
import '../../widgets/build_text_field.dart';

class AddPhoneScreen extends StatefulWidget {
  const AddPhoneScreen({Key? key}) : super(key: key);

  @override
  _AddPhoneScreenState createState() => _AddPhoneScreenState();
}

class _AddPhoneScreenState extends State<AddPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _verificationController = TextEditingController();
  String? _verificationId;
  bool _codeSent = false;
  String? _error;
  bool _isVerifying = false;
  Timer? _timer;
  int _timeLeft = 60;

  @override
  void dispose() {
    _phoneController.dispose();
    _verificationController.dispose();
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

  // 전화번호 형식을 국제 표준으로 변환
  String _formatPhoneNumber(String phoneNumber) {
    // 앞에 0이 있으면 제거하고 한국 국가 코드 추가
    if (phoneNumber.startsWith('0')) {
      return '+82' + phoneNumber.substring(1);
    }
    // 이미 +82로 시작하면 그대로 반환
    else if (phoneNumber.startsWith('+82')) {
      return phoneNumber;
    }
    // 그 외의 경우 앞에 +82 추가 (010으로 시작하는 경우 등)
    else {
      return '+82' + phoneNumber;
    }
  }

  Future<void> _verifyNewPhone() async {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      String phoneNumber = _phoneController.text.trim();
      if (phoneNumber.isEmpty) {
        setState(() {
          _error = '전화번호를 입력해주세요';
          _isVerifying = false;
        });
        return;
      }

      // 전화번호 형식 변환 (국가 코드 추가)
      phoneNumber = _formatPhoneNumber(phoneNumber);

      final authProvider = context.read<AppAuthProvider>();

      await authProvider.verifyPhone(
        phoneNumber: phoneNumber,
        onVerificationCompleted: (credential) async {
          // 자동 인증 완료 시 처리
          await _linkPhoneNumber(credential);
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
    if (_verificationId == null || _verificationController.text.isEmpty) {
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
      final authProvider = context.read<AppAuthProvider>();
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _verificationController.text,
      );

      await _linkPhoneNumber(credential);
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

  Future<void> _linkPhoneNumber(PhoneAuthCredential credential) async {
    try {
      final authProvider = context.read<AppAuthProvider>();
      final success = await authProvider.linkPhoneNumber(credential);

      // 성공 처리
      _timer?.cancel();

      if (success && mounted) {
        // 성공 다이얼로그 표시
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('전화번호 추가 완료'),
            content: Text('전화번호가 성공적으로 추가되었습니다.'),
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

        // 이전 화면으로 돌아가기
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _error = '전화번호 추가에 실패했습니다: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('휴대전화 추가'),
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
                    '계정에 휴대전화 번호를 추가합니다',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  BuildTextFieldWithButton(
                    context: context,
                    controller: _phoneController,
                    label: '휴대전화 번호',
                    buttonText: '인증번호 받기',
                    onPressed: _isVerifying ? () {} : _verifyNewPhone,
                    keyboardType: TextInputType.phone,
                    error: _error,
                  ),
                  if (_codeSent) ...[
                    SizedBox(height: 16),
                    BuildTextFieldWithButton(
                      context: context,
                      controller: _verificationController,
                      label: '인증번호 ($_formatTime)',
                      buttonText: '확인',
                      onPressed: _isVerifying ? () {} : _verifyCode,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  SizedBox(height: 16),
                  Text(
                    '* 휴대전화 번호로 인증번호가 전송됩니다.\n* 추가하신 전화번호는 로그인에 사용할 수 있습니다.',
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
