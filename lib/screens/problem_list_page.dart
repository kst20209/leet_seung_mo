import 'package:flutter/material.dart';
import '../widgets/tag_chip.dart';
import './problem_data.dart';

class ProblemListPage extends StatelessWidget {
  final String title;
  final List<Problem> items;

  const ProblemListPage({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ProblemListItem(problem: item);
        },
      ),
    );
  }
}

class ProblemListItem extends StatelessWidget {
  final Problem problem;

  const ProblemListItem({Key? key, required this.problem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 하드코딩된 값들
    final bool isSolved = false;
    final String solveTime = '5분 30초';
    final bool isFavorite = true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          // Navigate to problem solving page
          Navigator.pushNamed(
            context,
            '/problem_solving',
            arguments: problem,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      problem.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          problem.title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          problem.description,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      // Toggle favorite status
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    problem.tags.map((tag) => TagChip(label: tag)).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSolved ? 'Solved' : 'Not Solved',
                    style: TextStyle(
                      color: isSolved ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isSolved)
                    Text(
                      'Time: $solveTime',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
