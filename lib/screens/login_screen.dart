import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_data_provider.dart';
import 'signup/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AppAuthProvider _authProvider;

  String? _verificationId;
  bool _codeSent = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // 상태바 스타일 설정
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AppAuthProvider>(context, listen: false);
  }

  Future<void> _verifyPhone() async {
    final authProvider = context.read<AppAuthProvider>();
    String phoneNumber = _phoneController.text;
    if (!phoneNumber.startsWith('+82')) {
      phoneNumber = '+82' + phoneNumber.substring(1);
    }

    await authProvider.verifyPhone(
      phoneNumber: phoneNumber,
      onVerificationCompleted: (credential) async {
        // Auto verification completed
      },
      onCodeSent: (verificationId) {
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
          _error = null;
        });
      },
      onError: (error) {
        setState(() {
          _error = error;
        });
      },
    );
  }

  Future<void> _verifyCode() async {
    if (_verificationId == null || _codeController.text.isEmpty) {
      setState(() {
        _error = '인증번호를 입력해주세요';
      });
      return;
    }

    final authProvider = context.read<AppAuthProvider>();
    final success = await authProvider.verifyCode(
      _verificationId!,
      _codeController.text,
    );

    if (!success && mounted) {
      setState(() {
        _error = authProvider.error;
      });
    }
  }

  @override
  void dispose() {
    _authProvider.removeLoginSuccessCallback();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '리승모',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: '휴대폰 번호',
                    border: OutlineInputBorder(),
                    enabled: !_codeSent,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),
                if (_codeSent)
                  TextFormField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: '인증번호',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                SizedBox(height: 16),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _codeSent ? _verifyCode : _verifyPhone,
                  child: Text(_codeSent ? '로그인' : '인증번호 받기'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  child: Text('회원가입'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
