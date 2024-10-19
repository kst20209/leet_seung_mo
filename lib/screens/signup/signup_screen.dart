import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'build_terms_page.dart';
import 'email_password_screen.dart';
import 'phone_verification_screen.dart';
import 'nickname_screen.dart';
import 'build_thankyou_page.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _agreedToTerms = false;
  String? _email;
  String? _password;
  String? _phoneNumber;
  String? _nickname;
  String? _verificationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          BuildTermsPage(
            agreedToTerms: _agreedToTerms,
            onAgreedToTermsChanged: (value) {
              setState(() {
                _agreedToTerms = value;
              });
            },
            onNextPressed: () {
              if (_agreedToTerms) {
                _goToNextPage();
              }
            },
          ),
          EmailPasswordScreen(onNext: _setEmailAndPassword),
          PhoneVerificationScreen(
            onSendCode: _sendVerificationCode,
            onVerifyCode: _verifyCode,
            onNext: _setPhoneNumber,
          ),
          NicknameScreen(onNext: _setNickname),
          BuildThankYouPage(
            onStartPressed: () {
              // TODO: Navigate to the main screen
              print('Navigate to main screen');
            },
          ),
        ],
      ),
    );
  }

  void _goToNextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  void _setEmailAndPassword(String email, String password) {
    setState(() {
      _email = email;
      _password = password;
    });
    _goToNextPage();
  }

  void _sendVerificationCode(String phoneNumber) async {
    // Implement Firebase phone verification logic here
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void _verifyCode(String smsCode) async {
    if (_verificationId != null) {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      try {
        await FirebaseAuth.instance.signInWithCredential(credential);
        _goToNextPage();
      } catch (e) {
        print("Error verifying SMS code: $e");
      }
    }
  }

  void _setPhoneNumber(String phoneNumber) {
    setState(() {
      _phoneNumber = phoneNumber;
    });
    _goToNextPage();
  }

  void _setNickname(String nickname) {
    setState(() {
      _nickname = nickname;
    });
    _finishSignUp();
  }

  void _finishSignUp() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email!,
        password: _password!,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': _email,
        'phoneNumber': _phoneNumber,
        'nickname': _nickname,
        'createdAt': FieldValue.serverTimestamp(),
        'currentPoints': 0,
        'purchasedProblemSets': [],
        'lastSolvedProblems': [],
      });

      _goToNextPage(); // Go to Thank You page
    } catch (e) {
      // TODO: Handle errors and show appropriate messages to the user
      print('Error during sign up: $e');
    }
  }
}
