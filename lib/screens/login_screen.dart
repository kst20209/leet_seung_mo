// lib/screens/login_screen.dart
// 파일 전체를 다음과 같이 변경

import 'package:flutter/material.dart';
import 'signup/login_with_email_screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 즉시 이메일 로그인 화면으로 리다이렉트
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginWithEmailScreen()),
      );
    });

    // 로딩 화면
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
