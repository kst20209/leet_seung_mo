import 'package:flutter/material.dart';
import './tag_chip.dart';
import '../screens/problem_sell_detail.dart';

class ProblemItem extends StatelessWidget {
  final Map<String, dynamic> problemData;

  const ProblemItem({super.key, required this.problemData});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(
            problemData['imageUrl'] ?? 'https://via.placeholder.com/150'),
        title: Text(problemData['title'] ?? '제목 없음'),
        subtitle: Wrap(
          spacing: 4,
          children: (problemData['tags'] as List<dynamic>? ?? [])
              .map((tag) => TagChip(label: tag))
              .toList(),
        ),
        trailing: Text(
          'P ${problemData['price'] ?? 0}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProblemSellDetail(problemData: problemData),
            ),
          );
        },
      ),
    );
  }
}
