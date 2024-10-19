import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _agreedToTerms = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _nicknameError;
  String? _phoneError;
  String? _verificationError;
  String? _verificationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildTermsPage(),
            _buildSignUpForm(),
            _buildThankYouPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 40),
          Text(
            '개인정보 처리방침',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.brown[700]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Text(
                    '여기에 개인정보 처리방침 내용을 넣으세요...',
                    style: TextStyle(fontSize: 16, color: Colors.brown[600]),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          CheckboxListTile(
            title:
                Text('위 내용에 동의합니다', style: TextStyle(color: Colors.brown[700])),
            value: _agreedToTerms,
            activeColor: Colors.brown[400],
            onChanged: (bool? value) {
              setState(() {
                _agreedToTerms = value ?? false;
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text('다음', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[400],
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _agreedToTerms
                ? () => _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 40),
                    Text(
                      '회원가입',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[700]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    _buildTextField(
                      controller: _emailController,
                      label: '이메일',
                      error: _emailError,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    _buildTextField(
                      controller: _passwordController,
                      label: '비밀번호',
                      error: _passwordError,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    _buildTextField(
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
                    SizedBox(height: 24),
                    _buildTextFieldWithButton(
                      controller: _nicknameController,
                      label: '닉네임',
                      error: _nicknameError,
                      buttonText: '중복 확인',
                      onPressed: _checkNicknameDuplicate,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '닉네임을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    _buildTextFieldWithButton(
                      controller: _phoneController,
                      label: '휴대폰 번호',
                      error: _phoneError,
                      buttonText: '인증번호 전송',
                      onPressed: _sendVerificationCode,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '휴대폰 번호를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    _buildTextFieldWithButton(
                      controller: _verificationCodeController,
                      label: '인증번호',
                      error: _verificationError,
                      buttonText: '확인',
                      onPressed: _verifyCode,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '인증번호를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 40),
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
            child: Text('가입하기', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[400],
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _signUp,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? error,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.brown[50],
          ),
          obscureText: obscureText,
          validator: validator,
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 12),
            child: Text(
              error,
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildTextFieldWithButton({
    required TextEditingController controller,
    required String label,
    String? error,
    required String buttonText,
    required VoidCallback onPressed,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: label,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.brown[50],
                    ),
                    validator: validator,
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 12),
                      child: Text(
                        error,
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              child: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[300],
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onPressed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThankYouPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 100, color: Colors.green[600]),
          SizedBox(height: 30),
          Text(
            '가입해주셔서 감사합니다!',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.brown[700]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          ElevatedButton(
            child: Text('시작하기', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[400],
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              // TODO: 메인 화면으로 이동
            },
          ),
        ],
      ),
    );
  }

  void _checkNicknameDuplicate() {
    // TODO: 닉네임 중복 확인 로직 구현
    setState(() {
      _nicknameError = null; // 또는 중복 시 에러 메시지 설정
    });
  }

  void _sendVerificationCode() {
    // TODO: 휴대폰 인증 로직 구현
    setState(() {
      _phoneError = null; // 또는 오류 발생 시 에러 메시지 설정
    });
  }

  void _verifyCode() {
    // TODO: 인증번호 확인 로직 구현
    setState(() {
      _verificationError = null; // 또는 오류 발생 시 에러 메시지 설정
    });
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      // TODO: Firebase를 사용한 회원가입 로직 구현
      // 이메일/비밀번호로 계정 생성
      // 휴대폰 인증
      // Firestore에 사용자 정보 저장

      // 성공 시 다음 페이지로 이동
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }
}
