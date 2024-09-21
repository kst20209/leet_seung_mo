import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const TagChip({Key? key, required this.label, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
      ),
    );
  }
}
