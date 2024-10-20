import 'package:flutter/material.dart';
import '../../widgets/build_text_field.dart';

class NicknameScreen extends StatefulWidget {
  final Future<void> Function() onNext;

  NicknameScreen({required this.onNext});

  @override
  _NicknameScreenState createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  String? _nicknameError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('닉네임 입력'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BuildTextFieldWithButton(
                        context: context,
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
              child: Text('가입 완료', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onNext();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _checkNicknameDuplicate() async {
    // TODO: Implement nickname duplication check
    // This should involve a call to your backend or Firebase to check if the nickname is already in use
    // For now, we'll just simulate a check
    setState(() {
      _nicknameError = null; // Clear any previous errors
      // Simulating a check - in a real app, this would be the result of an API call
      if (_nicknameController.text == "takenNickname") {
        _nicknameError = "이미 사용 중인 닉네임입니다";
      } else {
        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용 가능한 닉네임입니다')),
        );
      }
    });
  }
}
