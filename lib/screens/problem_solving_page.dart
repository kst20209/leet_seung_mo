export 'problem_solving_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui' as ui;
import '../models/models.dart';
import '../widgets/timer_widget.dart';
import '../utils/custom_network_image.dart';

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
  OverlayEntry? _colorOverlay;
  OverlayEntry? _strokeWidthOverlay;

  final List<Color> colors = [Colors.black, Colors.red, Colors.blue];
  final List<double> strokeWidths = [1.0, 2.0, 3.0];

  final GlobalKey _toolbarKey = GlobalKey();

  int _elapsedSeconds = 0;
  GlobalKey<TimerWidgetState> timerKey = GlobalKey<TimerWidgetState>();

  @override
  void dispose() {
    _removeOverlays();
    super.dispose();
  }

  void _removeOverlays() {
    _colorOverlay?.remove();
    _strokeWidthOverlay?.remove();
    _colorOverlay = null;
    _strokeWidthOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showStopSolvingDialog();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.problem.title),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _showStopSolvingDialog,
          ),
          actions: [
            TextButton(
              child: Text('정답 제출', style: TextStyle(color: Colors.black)),
              onPressed: () {
                _showAnswerSubmissionDialog();
              },
            ),
          ],
        ),
        body: GestureDetector(
          onTap: _removeOverlays,
          child: Column(
            children: [
              _buildToolbar(),
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
                        child: CustomNetworkImage(
                          imageUrl: widget.problem.problemImage,
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
                                DrawingPoint(event.localPosition, selectedColor,
                                    strokeWidth)
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
                                  event.localPosition,
                                  selectedColor,
                                  strokeWidth));
                            }
                          });
                        }
                      },
                      onPointerUp: (PointerUpEvent event) {
                        if (event.kind == PointerDeviceKind.stylus) {
                          setState(() {
                            currentPosition = null;
                            if (!isEraserMode) {
                              strokes.add(List.from(currentStroke));
                              currentStroke.clear();
                            }
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
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      key: _toolbarKey,
      padding: EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMainColorButton(),
          SizedBox(width: 20),
          _buildMainStrokeWidthButton(),
          SizedBox(width: 20),
          IconButton(
            icon: Icon(Icons.edit),
            color: isEraserMode ? Colors.grey : Colors.black,
            onPressed: () {
              setState(() {
                isEraserMode = false;
              });
            },
          ),
          SizedBox(width: 20),
          IconButton(
            icon: Icon(Icons.cleaning_services),
            color: isEraserMode ? Colors.red : Colors.black,
            onPressed: () {
              setState(() {
                isEraserMode = true;
              });
            },
          ),
          SizedBox(width: 20),
          TimerWidget(
            key: timerKey,
            onTimerUpdate: (seconds) {
              _elapsedSeconds = seconds;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainColorButton() {
    return GestureDetector(
      onTap: () {
        _toggleColorMenu();
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
        _toggleStrokeWidthMenu();
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

  void _toggleColorMenu() {
    _removeOverlays();
    _colorOverlay = _createColorOverlay();
    Overlay.of(context).insert(_colorOverlay!);
  }

  void _toggleStrokeWidthMenu() {
    _removeOverlays();
    _strokeWidthOverlay = _createStrokeWidthOverlay();
    Overlay.of(context).insert(_strokeWidthOverlay!);
  }

  OverlayEntry _createColorOverlay() {
    RenderBox renderBox =
        _toolbarKey.currentContext!.findRenderObject() as RenderBox;
    var offset = renderBox.localToGlobal(Offset.zero);
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + size.height,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: colors.map((color) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: _buildColorButton(color),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  OverlayEntry _createStrokeWidthOverlay() {
    RenderBox renderBox =
        _toolbarKey.currentContext!.findRenderObject() as RenderBox;
    var offset = renderBox.localToGlobal(Offset.zero);
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + size.height,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: strokeWidths.map((width) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: _buildStrokeWidthButton(width),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
          _removeOverlays();
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
          _removeOverlays();
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: strokeWidth == width ? Colors.grey[400] : Colors.transparent,
        ),
        child: Icon(Icons.circle, size: width * 6, color: Colors.black),
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
    timerKey.currentState?.pauseTimer();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('정답 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('걸린 시간: ${_formatTime(_elapsedSeconds)}'),
              ...List.generate(5, (index) {
                return ListTile(
                  title: Text('${index + 1}번'),
                  onTap: () {
                    // 여기에 정답 제출 로직 추가
                    Navigator.of(context).pop();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
