export 'problem_solving_page.dart';
import 'package:flutter/material.dart';
import './problem_data.dart';

class ProblemSolvingPage extends StatefulWidget {
  final ProblemData problemData;

  ProblemSolvingPage({Key? key, required this.problemData}) : super(key: key);

  @override
  _ProblemSolvingPageState createState() => _ProblemSolvingPageState();
}

class _ProblemSolvingPageState extends State<ProblemSolvingPage> {
  bool isTimerPaused = false;
  Color selectedColor = Colors.black;
  double strokeWidth = 2.0;
  bool isEraserMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.problemData.title),
        actions: [
          TextButton(
            child: Text(
              isTimerPaused ? '계속 풀기' : '일시정지',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              setState(() {
                isTimerPaused = !isTimerPaused;
              });
            },
          ),
          TextButton(
            child: Text('그만 풀기', style: TextStyle(color: Colors.black)),
            onPressed: _showStopSolvingDialog,
          ),
          TextButton(
            child: Text('정답 제출', style: TextStyle(color: Colors.black)),
            onPressed: () {
              _showAnswerSubmissionDialog();
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildToolbar(),
            Expanded(
              child: Stack(
                children: [
                  Image.network(
                    widget.problemData.problemImage,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  CustomPaint(
                    painter: DrawingPainter([]),
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStopSolvingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('풀이 중단'),
          content: Text('현재까지의 풀이과정이 저장되지 않습니다.'),
          actions: <Widget>[
            TextButton(
              child: Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('예'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildColorButton(Colors.black),
          _buildColorButton(Colors.red),
          _buildColorButton(Colors.blue),
          _buildStrokeWidthSlider(),
          IconButton(
            icon: Icon(Icons.edit),
            color: isEraserMode ? Colors.grey : Colors.black,
            onPressed: () {
              setState(() {
                isEraserMode = false;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.clear),
            color: isEraserMode ? Colors.red : Colors.black,
            onPressed: () {
              setState(() {
                isEraserMode = true;
              });
            },
          ),
          _buildTimer(),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
          isEraserMode = false;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selectedColor == color ? Colors.white : Colors.grey,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildStrokeWidthSlider() {
    return Container(
      width: 150,
      child: Slider(
        value: strokeWidth,
        min: 1,
        max: 10,
        divisions: 9,
        label: strokeWidth.round().toString(),
        onChanged: (double value) {
          setState(() {
            strokeWidth = value;
          });
        },
      ),
    );
  }

  Widget _buildTimer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '00:00',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAnswerSubmissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('정답 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return ListTile(
                title: Text('${index + 1}번'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              );
            }),
          ),
        );
      },
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;

  DrawingPainter(this.drawingPoints);

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DrawingPoint {
  final Offset offset;
  final Paint paint;

  DrawingPoint(this.offset, this.paint);
}
