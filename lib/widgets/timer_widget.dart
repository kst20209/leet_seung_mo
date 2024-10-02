import 'dart:async';
import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final Function(int) onTimerUpdate;

  const TimerWidget({Key? key, required this.onTimerUpdate}) : super(key: key);

  @override
  TimerWidgetState createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;
  int _seconds = 0;
  bool _isTimerPaused = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel(); // 기존 타이머가 있다면 취소
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isTimerPaused) {
        setState(() {
          _seconds++;
          widget.onTimerUpdate(_seconds);
        });
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void pauseTimer() {
    _isTimerPaused = true;
  }

  void resumeTimer() {
    _isTimerPaused = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatTime(_seconds),
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
