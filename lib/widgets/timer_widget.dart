import 'dart:async';
import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final Function(int) onTimerUpdate;
  final int initialSeconds;

  const TimerWidget({
    Key? key,
    required this.onTimerUpdate,
    this.initialSeconds = 0,
  }) : super(key: key);

  @override
  TimerWidgetState createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;
  late int _seconds;
  bool _isTimerPaused = false;

  @override
  void initState() {
    super.initState();
    _seconds = widget.initialSeconds;
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

  void resetTimer() {
    setState(() {
      _seconds = 0;
      _isTimerPaused = false;
      widget.onTimerUpdate(_seconds); // 부모 위젯에 업데이트 알림
    });

    // 타이머 재시작
    _startTimer();
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
