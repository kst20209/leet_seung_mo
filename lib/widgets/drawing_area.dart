import 'dart:ui';
import 'package:flutter/material.dart';

class DrawingArea extends StatelessWidget {
  final Widget child;
  final Function(PointerEvent) onStylusDown;
  final Function(PointerEvent) onStylusMove;
  final Function(PointerEvent) onStylusUp;

  const DrawingArea({
    Key? key,
    required this.child,
    required this.onStylusDown,
    required this.onStylusMove,
    required this.onStylusUp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      // 스타일러스 입력에 대한 스크롤 동작을 비활성화
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse
        }, // 스타일러스는 제외
      ),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          if (event.kind == PointerDeviceKind.stylus) {
            onStylusDown(event);
          }
        },
        onPointerMove: (event) {
          if (event.kind == PointerDeviceKind.stylus) {
            onStylusMove(event);
          }
        },
        onPointerUp: (event) {
          if (event.kind == PointerDeviceKind.stylus) {
            onStylusUp(event);
          }
        },
        child: child,
      ),
    );
  }
}
