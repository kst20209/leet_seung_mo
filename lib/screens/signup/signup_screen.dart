import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'build_terms_page.dart';
import 'email_password_screen.dart';
import 'phone_verification_screen.dart';
import 'nickname_screen.dart';
import 'build_thankyou_page.dart';
import '../../utils/firebase_service.dart';
import '../../utils/user_repository.dart';
import '../../utils/data_manager.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final PageController _pageController = PageController();
  late final UserRepository _userRepository;
  int _currentPage = 0;
  bool _agreedToTerms = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    final firebaseService = FirebaseService();
    _userRepository = UserRepository(firebaseService);
    DataManager().initialize(_userRepository);
  }

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
          EmailPasswordScreen(
            onNext: _goToNextPage,
          ),
          PhoneVerificationScreen(
            onNext: _goToNextPage,
          ),
          NicknameScreen(
            onNext: _goToNextPage,
          ),
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

  Future<void> _goToNextPage() async {
    if (_currentPage < 4) {
      await _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
    }
  }

  void _finishSignUp() async {
    try {
      if (_currentUser == null) {
        throw Exception('User not created');
      }
      await _goToNextPage(); // Go to Thank You page
    } catch (e) {}
  }
}
