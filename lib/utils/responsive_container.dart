import 'package:flutter/material.dart';
import 'dart:math';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidthPercentage; // 화면 대비 최대 너비 비율
  final double? absoluteMaxWidth; // 절대적인 최대 너비
  final Alignment alignment; // 컨테이너 정렬

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.maxWidthPercentage = 0.8, // 기본값 80%
    this.absoluteMaxWidth = 800.0, // 기본값 800.0
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 600은 태블릿 기준점
        if (constraints.maxWidth <= 600) {
          // 모바일 화면에서는 제한 없이 전체 너비 사용
          return Container(
            padding: padding,
            width: constraints.maxWidth,
            child: child,
          );
        }

        // 태블릿 이상에서는 너비 제한 적용
        double maxWidth = min(
          constraints.maxWidth * (maxWidthPercentage ?? 1),
          absoluteMaxWidth ?? double.infinity,
        );

        return Align(
          alignment: alignment,
          child: Container(
            padding: padding,
            width: maxWidth,
            child: child,
          ),
        );
      },
    );
  }
}
