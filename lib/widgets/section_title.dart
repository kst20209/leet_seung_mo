import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onMorePressed; // 선택적 더보기 콜백
  final String moreText; // 더보기 텍스트 커스터마이징 가능
  final EdgeInsetsGeometry padding;

  const SectionTitle(
    this.title, {
    Key? key,
    required this.icon,
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
          Row(
            children: [
              Icon(
                icon,
                size: 24, // 텍스트 크기와 동일하게 설정
                color: Theme.of(context).colorScheme.secondary, // 테마 색상 사용
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
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
