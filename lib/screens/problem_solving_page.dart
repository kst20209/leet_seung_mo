export 'problem_solving_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../models/models.dart';

class ProblemSolvingPage extends StatefulWidget {
  final Problem problem;

  ProblemSolvingPage({Key? key, required this.problem}) : super(key: key);

  @override
  _ProblemSolvingPageState createState() => _ProblemSolvingPageState();
}

class _ProblemSolvingPageState extends State<ProblemSolvingPage> {
  bool isTimerPaused = false;
  Color selectedColor = Colors.black;
  double strokeWidth = 2.0;
  bool isEraserMode = false;
  List<List<DrawingPoint>> strokes = [];
  List<DrawingPoint> currentStroke = [];
  Offset? currentPosition;
  final double eraserWidth = 10.0;
  bool isColorMenuOpen = false;
  bool isStrokeWidthMenuOpen = false;

  final List<Color> colors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow
  ];
  final List<double> strokeWidths = [1.0, 2.0, 3.0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.problem.title),
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
      body: Column(
        children: [
          _buildToolbar(),
          if (isColorMenuOpen) _buildColorMenu(),
          if (isStrokeWidthMenuOpen) _buildStrokeWidthMenu(),
          Expanded(
            child: Stack(
              children: [
                Container(color: Colors.white),
                Positioned(
                  left: 20,
                  top: 20,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 40,
                    ),
                    child: Image.network(
                      widget.problem.problemImage,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (PointerDownEvent event) {
                    if (event.kind == PointerDeviceKind.stylus) {
                      setState(() {
                        currentPosition = event.localPosition;
                        if (isEraserMode) {
                          _erase(event.localPosition);
                        } else {
                          currentStroke = [
                            DrawingPoint(
                                event.localPosition, selectedColor, strokeWidth)
                          ];
                        }
                      });
                    }
                  },
                  onPointerMove: (PointerMoveEvent event) {
                    if (event.kind == PointerDeviceKind.stylus) {
                      setState(() {
                        currentPosition = event.localPosition;
                        if (isEraserMode) {
                          _erase(event.localPosition);
                        } else {
                          currentStroke.add(DrawingPoint(
                              event.localPosition, selectedColor, strokeWidth));
                        }
                      });
                    }
                  },
                  onPointerUp: (PointerUpEvent event) {
                    if (event.kind == PointerDeviceKind.stylus) {
                      currentPosition = null;
                      setState(() {
                        strokes.add(List.from(currentStroke));
                        currentStroke.clear();
                      });
                    }
                  },
                  child: CustomPaint(
                    painter: DrawingPainter(
                        strokes,
                        currentStroke,
                        isEraserMode,
                        currentPosition,
                        strokeWidth,
                        eraserWidth),
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _erase(Offset point) {
    strokes.removeWhere((stroke) => stroke.any(
        (drawPoint) => (drawPoint.offset - point).distance <= eraserWidth / 2));
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMainColorButton(),
          SizedBox(width: 16),
          _buildMainStrokeWidthButton(),
          SizedBox(width: 16),
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
            icon: Icon(Icons.cleaning_services),
            color: isEraserMode ? Colors.red : Colors.black,
            onPressed: () {
              setState(() {
                isEraserMode = true;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // 설정 기능 구현
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainColorButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isColorMenuOpen = !isColorMenuOpen;
          isStrokeWidthMenuOpen = false;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: selectedColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey, width: 2),
        ),
      ),
    );
  }

  Widget _buildMainStrokeWidthButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isStrokeWidthMenuOpen = !isStrokeWidthMenuOpen;
          isColorMenuOpen = false;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey, width: 2),
        ),
        child: Icon(Icons.circle, size: strokeWidth * 6, color: Colors.black),
      ),
    );
  }

  Widget _buildColorMenu() {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: colors.map((color) => _buildColorButton(color)).toList(),
      ),
    );
  }

  Widget _buildStrokeWidthMenu() {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: strokeWidths
            .map((width) => _buildStrokeWidthButton(width))
            .toList(),
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

  Widget _buildStrokeWidthButton(double width) {
    return GestureDetector(
      onTap: () {
        setState(() {
          strokeWidth = width;
          isStrokeWidthMenuOpen = false;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: strokeWidth == width ? Colors.grey[400] : Colors.transparent,
        ),
        child: Icon(Icons.circle, size: width * 6, color: Colors.black),
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
  final List<List<DrawingPoint>> strokes;
  final List<DrawingPoint> currentStroke;
  final bool isEraserMode;
  final Offset? currentPosition;
  final double strokeWidth;
  final double eraserWidth;

  DrawingPainter(this.strokes, this.currentStroke, this.isEraserMode,
      this.currentPosition, this.strokeWidth, this.eraserWidth);
  @override
  void paint(Canvas canvas, Size size) {
    for (var stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    _drawStroke(canvas, currentStroke);

    if (isEraserMode && currentPosition != null) {
      final eraserPaint = Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final eraserFillPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(currentPosition!, eraserWidth / 2, eraserFillPaint);
      canvas.drawCircle(currentPosition!, eraserWidth / 2, eraserPaint);
    }
  }

  void _drawStroke(Canvas canvas, List<DrawingPoint> stroke) {
    for (int i = 0; i < stroke.length - 1; i++) {
      canvas.drawLine(
          stroke[i].offset,
          stroke[i + 1].offset,
          Paint()
            ..color = stroke[i].color
            ..strokeWidth = stroke[i].strokeWidth
            ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class DrawingPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;

  DrawingPoint(this.offset, this.color, this.strokeWidth);
}
