import 'package:flutter/material.dart';

class BuildThankYouPage extends StatelessWidget {
  final VoidCallback onStartPressed;

  const BuildThankYouPage({
    Key? key,
    required this.onStartPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            onPressed: onStartPressed,
          ),
        ],
      ),
    );
  }
}
