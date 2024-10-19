import 'package:flutter/material.dart';

class BuildTermsPage extends StatelessWidget {
  final bool agreedToTerms;
  final ValueChanged<bool> onAgreedToTermsChanged;
  final VoidCallback onNextPressed;

  const BuildTermsPage({
    Key? key,
    required this.agreedToTerms,
    required this.onAgreedToTermsChanged,
    required this.onNextPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            value: agreedToTerms,
            activeColor: Colors.brown[400],
            onChanged: (bool? value) {
              onAgreedToTermsChanged(value ?? false);
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
            onPressed: agreedToTerms ? onNextPressed : null,
          ),
        ],
      ),
    );
  }
}
