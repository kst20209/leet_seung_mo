import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onMorePressed; // 선택적 더보기 콜백
  final String moreText; // 더보기 텍스트 커스터마이징 가능
  final EdgeInsetsGeometry padding;

  const SectionTitle(
    this.title, {
    Key? key,
    this.onMorePressed,
    this.moreText = '더보기',
    this.padding = const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (onMorePressed != null)
            TextButton(
              onPressed: onMorePressed,
              child: Text(moreText),
            ),
        ],
      ),
    );
  }
}
