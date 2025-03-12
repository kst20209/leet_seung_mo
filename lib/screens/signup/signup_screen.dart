import 'package:flutter/material.dart';
import 'package:leet_seung_mo/main.dart';
import 'package:leet_seung_mo/screens/signup/email_password_screen.dart';
// import 'phone_verification_screen.dart';
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

  @override
  void initState() {
    super.initState();
    final firebaseService = FirebaseService();
    _userRepository = UserRepository(firebaseService);
    DataManager().initialize(_userRepository);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            EmailPasswordScreen(
              onNext: _goToNextPage,
            ),
            NicknameScreen(
              onNext: _goToNextPage,
            ),
            BuildThankYouPage(
              onStartPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToNextPage() async {
    if (_currentPage < 2) {
      await _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
    }
  }
}
