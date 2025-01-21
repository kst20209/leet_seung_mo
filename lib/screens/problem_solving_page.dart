export 'problem_solving_page.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:no_screenshot/screenshot_snapshot.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/models.dart';
import '../utils/problem_solve_service.dart';
import '../widgets/drawing_area.dart';
import '../widgets/timer_widget.dart';
import '../utils/custom_network_image.dart';
import '../providers/user_data_provider.dart';
import 'dart:math';
import 'dart:io';
import 'package:flutter/services.dart';

class ProblemSolvingPage extends StatefulWidget {
  final Problem problem;

  ProblemSolvingPage({Key? key, required this.problem}) : super(key: key);

  @override
  _ProblemSolvingPageState createState() => _ProblemSolvingPageState();
}

class _ProblemSolvingPageState extends State<ProblemSolvingPage> {
  bool isTimerPaused = false;
  bool _isReviewMode = false;
  Color selectedColor = Colors.black;
  double strokeWidth = 2.0;
  bool isEraserMode = false;
  List<List<DrawingPoint>> problemStrokes = [];
  List<List<DrawingPoint>> solutionStrokes = [];
  final _noScreenshot = NoScreenshot.instance;

  int _currentPageIndex = 0;
  late final PageController _pageController;

  // 현재 활성화된 strokes (문제/해설)
  List<List<DrawingPoint>> _getActiveStrokes() {
    return _currentPageIndex == 0 ? problemStrokes : solutionStrokes;
  }

  List<DrawingPoint> currentStroke = [];

  // 스크롤 위치 추적을 위한 컨트롤러들
  final ScrollController problemScrollController = ScrollController();
  final ScrollController solutionScrollController = ScrollController();

  ScrollController get _currentScrollController => _currentPageIndex == 0
      ? problemScrollController
      : solutionScrollController;

  Offset? currentPosition;
  final double eraserWidth = 10.0;
  OverlayEntry? _colorOverlay;
  OverlayEntry? _strokeWidthOverlay;

  final List<Color> colors = [Colors.black, Colors.red, Colors.blue];
  final List<double> strokeWidths = [1.0, 2.0, 3.0];

  final GlobalKey _toolbarKey = GlobalKey();

  final ProblemSolveService _problemSolveService = ProblemSolveService();

  int _elapsedSeconds = 0;
  GlobalKey<TimerWidgetState> timerKey = GlobalKey<TimerWidgetState>();

  @override
  void initState() {
    super.initState();
    _checkProblemState();
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          _currentPageIndex = _pageController.page!.round();
        });
      }
    });

    // 스크린샷 방지 설정 추가
    if (Platform.isAndroid) {
      const platform = MethodChannel('flutter_secure_screen');
      try {
        platform.invokeMethod('preventScreenshot');
      } catch (e) {
        print('Error setting secure screen: $e');
      }
    }
    _noScreenshot.screenshotOff();
  }

  Future<void> _checkProblemState() async {
    final user = context.read<AppAuthProvider>().user;
    if (user == null) return;

    try {
      // 첫 조회 기록
      await _problemSolveService.recordFirstView(
        userId: user.uid,
        problemId: widget.problem.id,
      );

      final problemData = await context
          .read<UserDataProvider>()
          .getProblemData(widget.problem.id);

      if (problemData?['isSolved'] == true) {
        final latestAttemptId = problemData?['lastAttemptId'];
        if (latestAttemptId != null) {
          // 저장된 드로잉 데이터 로드
          final drawingData =
              await _problemSolveService.loadDrawingData(latestAttemptId);

          // 소요 시간 가져오기
          final attemptData = await _problemSolveService.getLatestAttemptData(
            user.uid,
            widget.problem.id,
          );

          final timeSpent = attemptData?['timeSpent'] as int?;

          if (mounted) {
            setState(() {
              _isReviewMode = true;
              problemStrokes = drawingData['problemStrokes'] ?? [];
              solutionStrokes = drawingData['solutionStrokes'] ?? [];
              if (timeSpent != null) {
                _elapsedSeconds = timeSpent;
                // 타이머를 멈추고 시간 설정
                timerKey = GlobalKey<TimerWidgetState>();
              }
              if (timeSpent != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  timerKey.currentState?.pauseTimer();
                });
              }
            });
          }
        }
      }
    } catch (e) {
      print('Error checking problem state: $e');
    }
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      const platform = MethodChannel('flutter_secure_screen');
      try {
        platform.invokeMethod('allowScreenshot');
      } catch (e) {
        print('Error removing secure screen: $e');
      }
    }

    _noScreenshot.screenshotOn();

    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    if (_pageController.page != null) {
      setState(() {
        _currentPageIndex = _pageController.page!.round();
      });
    }
  }

  void _removeOverlays() {
    _colorOverlay?.remove();
    _strokeWidthOverlay?.remove();
    _colorOverlay = null;
    _strokeWidthOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          _isReviewMode
              ? _showRestartConfirmation
              : _showAnswerSubmissionDialog;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.problem.title),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: !_isReviewMode ? _showStopSolvingDialog : _saveAndExit,
          ),
          actions: [
            TextButton(
              child: Text(_isReviewMode ? '다시 풀기' : '정답 제출',
                  style: TextStyle(color: Colors.black)),
              onPressed: _isReviewMode
                  ? _showRestartConfirmation
                  : _showAnswerSubmissionDialog,
            ),
          ],
        ),
        body: Column(
          children: [
            _buildToolbar(), // 스크롤과 무관하게 항상 상단에 고정
            Expanded(
              child: DrawingArea(
                onStylusDown: (event) {
                  _removeOverlays();
                  setState(() {
                    // 현재 스크롤 위치를 고려한 오프셋 계산
                    final scrollOffset = _currentScrollController.hasClients
                        ? _currentScrollController.offset
                        : 0.0;
                    final adjustedPosition =
                        event.localPosition + Offset(0, scrollOffset);
                    currentPosition = adjustedPosition;
                    if (isEraserMode) {
                      _erase(adjustedPosition);
                    } else {
                      currentStroke = [
                        DrawingPoint(
                            adjustedPosition, selectedColor, strokeWidth)
                      ];
                    }
                  });
                },
                onStylusMove: (event) {
                  setState(() {
                    final scrollOffset = _currentScrollController.hasClients
                        ? _currentScrollController.offset
                        : 0.0;
                    final adjustedPosition =
                        event.localPosition + Offset(0, scrollOffset);
                    currentPosition = adjustedPosition;
                    if (isEraserMode) {
                      _erase(adjustedPosition);
                    } else {
                      currentStroke.add(DrawingPoint(
                          adjustedPosition, selectedColor, strokeWidth));
                    }
                  });
                },
                onStylusUp: (event) {
                  setState(() {
                    currentPosition = null;
                    if (!isEraserMode && currentStroke.isNotEmpty) {
                      final simplifiedStroke = _simplifyStroke(currentStroke);
                      _getActiveStrokes().add(List.from(simplifiedStroke));
                      currentStroke.clear();
                      _repaintNotifier.value++;
                    }
                  });
                },
                child: PageView(
                  controller: _pageController,
                  physics: const PageScrollPhysics(),
                  children: [
                    SingleChildScrollView(
                      controller: problemScrollController,
                      child: _buildProblemArea(),
                    ),
                    if (_isReviewMode)
                      SingleChildScrollView(
                        controller: solutionScrollController,
                        child: _buildSolutionArea(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemArea() {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 2,
          color: Colors.white,
        ),
        Positioned(
          left: 20,
          top: 20,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: min(400, MediaQuery.of(context).size.width - 40),
            ),
            child: CustomNetworkImage(
              imageUrl: widget.problem.problemImage,
              fit: BoxFit.contain,
            ),
          ),
        ),
        RepaintBoundary(
          child: CustomPaint(
            painter: CompletedStrokesPainter(problemStrokes),
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 2,
            ),
          ),
        ),
        RepaintBoundary(
          child: CustomPaint(
            painter: CurrentStrokePainter(
              _currentPageIndex == 0 ? currentStroke : const [],
              isEraserMode,
              _currentPageIndex == 0 ? currentPosition : null,
              strokeWidth,
              eraserWidth,
            ),
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSolutionArea() {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 2,
          color: Colors.white,
        ),
        Positioned(
          left: 20,
          top: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  '해설',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: widget.problem.isWideSolution ?? false
                      ? min(800, MediaQuery.of(context).size.width - 40)
                      : min(400, MediaQuery.of(context).size.width - 40),
                ),
                child: CustomNetworkImage(
                  imageUrl: widget.problem.solutionImage,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        RepaintBoundary(
          child: CustomPaint(
            painter: CompletedStrokesPainter(solutionStrokes),
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 2,
            ),
          ),
        ),
        RepaintBoundary(
          child: CustomPaint(
            painter: CurrentStrokePainter(
              _currentPageIndex == 1 ? currentStroke : const [],
              isEraserMode,
              _currentPageIndex == 1 ? currentPosition : null,
              strokeWidth,
              eraserWidth,
            ),
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 2,
            ),
          ),
        ),
      ],
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
            initialSeconds: _elapsedSeconds,
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
    if (_colorOverlay != null) {
      _removeOverlays();
      return;
    }
    _removeOverlays();
    _colorOverlay = _createColorOverlay();
    Overlay.of(context).insert(_colorOverlay!);
  }

  void _toggleStrokeWidthMenu() {
    if (_strokeWidthOverlay != null) {
      _removeOverlays();
      return;
    }
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
                  color: Colors.black.withValues(alpha: 0.2),
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
                    color: Colors.white.withValues(alpha: 0.8),
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
                  color: Colors.black.withValues(alpha: 0.2),
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
                    color: Colors.white.withValues(alpha: 0.8),
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

  void _updateCompletedStrokes(List<List<DrawingPoint>> newStrokes) {
    setState(() {
      if (_currentPageIndex == 0) {
        problemStrokes = newStrokes;
      } else {
        solutionStrokes = newStrokes;
      }
    });
  }

  void _erase(Offset point) {
    final eraserRadius = eraserWidth / 2;

    var activeStrokes = List<List<DrawingPoint>>.from(_getActiveStrokes());
    bool strokesChanged = false;

    activeStrokes.removeWhere((stroke) {
      bool shouldRemove = stroke.any(
          (drawPoint) => (drawPoint.offset - point).distance <= eraserRadius);
      if (shouldRemove) strokesChanged = true;
      return shouldRemove;
    });

    if (strokesChanged) {
      _updateCompletedStrokes(activeStrokes);
    }

    if (currentStroke.any(
        (drawPoint) => (drawPoint.offset - point).distance <= eraserRadius)) {
      currentStroke.clear();
    }
  }

  List<DrawingPoint> _simplifyStroke(List<DrawingPoint> points,
      {double epsilon = 0.3}) {
    if (points.length <= 2) return points;

    double maxDistance = 0;
    int index = 0;
    final start = points.first;
    final end = points.last;

    for (int i = 1; i < points.length - 1; i++) {
      double distance = _perpendicularDistance(points[i], start, end);
      if (distance > maxDistance) {
        index = i;
        maxDistance = distance;
      }
    }

    if (maxDistance > epsilon) {
      var firstHalf = _simplifyStroke(points.sublist(0, index + 1));
      var secondHalf = _simplifyStroke(points.sublist(index));
      return [...firstHalf.sublist(0, firstHalf.length - 1), ...secondHalf];
    }

    return [points.first, points.last];
  }

  double _perpendicularDistance(
      DrawingPoint point, DrawingPoint start, DrawingPoint end) {
    final area = ((end.offset.dx - start.offset.dx) *
                (start.offset.dy - point.offset.dy) -
            (start.offset.dx - point.offset.dx) *
                (end.offset.dy - start.offset.dy))
        .abs();
    final bottom = sqrt((end.offset.dx - start.offset.dx) *
            (end.offset.dx - start.offset.dx) +
        (end.offset.dy - start.offset.dy) * (end.offset.dy - start.offset.dy));
    return area / bottom;
  }

  void _showStopSolvingDialog() {
    _removeOverlays();
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

  void _showAnswerSubmissionDialog() {
    timerKey.currentState?.pauseTimer();
    _removeOverlays();
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
                final answer = (index + 1).toString();
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      answer,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text('$answer번'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _handleAnswerSubmission(answer);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // 정답 제출 처리
  Future<void> _handleAnswerSubmission(String selectedAnswer) async {
    final authProvider = context.read<AppAuthProvider>();
    final userDataProvider = context.read<UserDataProvider>();
    final user = authProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // 타이머 정지
      timerKey.currentState?.pauseTimer();

      // 정답 여부 확인
      final isCorrect = selectedAnswer == widget.problem.correctAnswer;

      // Firestore에 데이터 저장
      final attemptId = await _problemSolveService.saveAttempt(
        userId: user.uid,
        problemId: widget.problem.id,
        submittedAnswer: selectedAnswer,
        isCorrect: isCorrect,
        timeSpent: _elapsedSeconds,
        problemStrokes: problemStrokes,
        solutionStrokes: solutionStrokes,
      );

      // UI 상태 업데이트
      if (attemptId != null) {
        await userDataProvider.markProblemAsSolved(
          widget.problem.id, attemptId, isCorrect, // attemptId 전달
        );
      }

      // 로딩 닫기
      Navigator.of(context).pop();

      // 결과 모달 표시
      setState(() {
        _isReviewMode = true;
      });
      if (mounted) {
        _showResultModal(isCorrect);
      }
    } catch (e) {
      Navigator.of(context).pop(); // 로딩 닫기
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _showResultModal(bool isCorrect) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.close,
                  size: 64,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
                SizedBox(height: 16),
                Text(
                  isCorrect ? '정답입니다!' : '오답입니다.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer, size: 20),
                    SizedBox(width: 8),
                    Text(
                      _formatTime(_elapsedSeconds),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRestartConfirmation() {
    _removeOverlays();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('다시 풀기'),
          content: Text('정말로 다시 푸시겠습니까?\n현재 작성 중인 내용이 모두 초기화됩니다.'),
          actions: [
            TextButton(
              child: Text('아니오'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('예'),
              onPressed: () {
                Navigator.of(context).pop();
                _restartProblem();
              },
            ),
          ],
        );
      },
    );
  }

  // 문제를 푼 후 저장하고 나가기
  Future<void> _saveAndExit() async {
    final user = context.read<AppAuthProvider>().user;
    if (user == null) return;

    _removeOverlays();
    try {
      await _problemSolveService.saveReviewState(
        userId: user.uid,
        problemId: widget.problem.id,
        problemStrokes: problemStrokes,
        solutionStrokes: solutionStrokes,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _restartProblem() async {
    try {
      await context.read<UserDataProvider>().markProblemUnsolved(
            widget.problem.id,
          );

      setState(() {
        _isReviewMode = false;
        problemStrokes.clear();
        solutionStrokes.clear();
        currentStroke.clear();
        _elapsedSeconds = 0;
        _repaintNotifier.value = 0;
        timerKey.currentState?.resetTimer();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('문제 재시작 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

final ValueNotifier<int> _repaintNotifier = ValueNotifier(0);

class CompletedStrokesPainter extends CustomPainter {
  final List<List<DrawingPoint>> strokes;

  CompletedStrokesPainter(this.strokes) : super(repaint: _repaintNotifier);

  @override
  void paint(Canvas canvas, Size size) {
    for (var stroke in strokes) {
      _drawStroke(canvas, stroke);
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
  bool shouldRepaint(CompletedStrokesPainter oldDelegate) {
    if (oldDelegate.strokes.length != strokes.length) return true;

    for (int i = 0; i < strokes.length; i++) {
      if (oldDelegate.strokes[i].length != strokes[i].length) return true;
      for (int j = 0; j < strokes[i].length; j++) {
        if (oldDelegate.strokes[i][j] != strokes[i][j]) return true;
      }
    }

    return false;
  }
}

class CurrentStrokePainter extends CustomPainter {
  final List<DrawingPoint> currentStroke;
  final bool isEraserMode;
  final Offset? currentPosition;
  final double strokeWidth;
  final double eraserWidth;

  CurrentStrokePainter(this.currentStroke, this.isEraserMode,
      this.currentPosition, this.strokeWidth, this.eraserWidth);

  @override
  void paint(Canvas canvas, Size size) {
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
  bool shouldRepaint(CurrentStrokePainter oldDelegate) {
    return true;
  }
}

class DrawingPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;

  DrawingPoint(this.offset, this.color, this.strokeWidth);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawingPoint &&
          offset == other.offset &&
          color == other.color &&
          strokeWidth == other.strokeWidth;

  @override
  int get hashCode => Object.hash(offset, color, strokeWidth);
}
