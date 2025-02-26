import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/auth_provider.dart';
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
  final _phoneController = TextEditingController();
  final _verificationController = TextEditingController();
  String? _verificationId;
  bool _codeSent = false;
  String? _error;
  bool _isVerifying = false;
  Timer? _timer;
  int _timeLeft = 60;

  @override
  void initState() {
    super.initState();
    // 현재 전화번호 표시
    final user = context.read<AppAuthProvider>().user;
    if (user?.phoneNumber != null) {
      _phoneController.text = user!.phoneNumber!;
    }
  }

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

  Future<void> _verifyCurrentPhone() async {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AppAuthProvider>();
      String phoneNumber = _phoneController.text;
      if (!phoneNumber.startsWith('+82')) {
        phoneNumber = '+82' + phoneNumber.substring(1);
      }

      await authProvider.verifyPhone(
        phoneNumber: phoneNumber,
        onVerificationCompleted: (credential) async {
          // Auto verification completed
          setState(() {
            _codeSent = false;
          });
          _timer?.cancel();
          // 인증 성공 시 바로 다음 단계로 이동
          widget.onVerificationSuccess();
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
      final success = await authProvider.verifyCode(
        _verificationId!,
        _verificationController.text,
      );

      if (success) {
        _timer?.cancel();
        widget.onVerificationSuccess();
      } else {
        setState(() {
          _error = '잘못된 인증번호입니다.';
        });
      }
    } finally {
      setState(() {
        _isVerifying = false;
      });
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
                    '계정 삭제를 위해\n본인 확인이 필요합니다',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  BuildTextFieldWithButton(
                    context: context,
                    controller: _phoneController,
                    label: '현재 전화번호',
                    buttonText: '인증번호 받기',
                    onPressed: _isVerifying ? () {} : _verifyCurrentPhone,
                    keyboardType: TextInputType.phone,
                    error: _error,
                    readOnly: true, // 현재 전화번호는 수정 불가
                  ),
                  if (_codeSent) ...[
                    SizedBox(height: 16),
                    BuildTextFieldWithButton(
                      context: context,
                      controller: _verificationController,
                      label: '인증번호 ($_formatTime)',
                      buttonText: '확인',
                      onPressed: _verifyCode,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  SizedBox(height: 16),
                  Text(
                    '* 현재 전화번호로 인증번호가 전송됩니다.\n* 본인 확인 후 계정 삭제가 진행됩니다.',
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
