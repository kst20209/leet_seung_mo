import 'package:flutter/material.dart';
import './tag_chip.dart';
import '../screens/problem_sell_detail.dart';

class ProblemItem extends StatelessWidget {
  final Map<String, dynamic> problemData;

  ProblemItem({required this.problemData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProblemSellDetail(problemData: problemData),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    problemData['imageUrl'] ??
                        'https://via.placeholder.com/150',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      problemData['title'] ?? '제목 없음',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: (problemData['tags'] as List<dynamic>? ?? [])
                          .map((tag) => TagChip(label: tag))
                          .toList(),
                    ),
                    SizedBox(height: 4),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text('P ${problemData['price'] ?? 0}',
                          style: Theme.of(context).textTheme.headlineMedium),
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
}
