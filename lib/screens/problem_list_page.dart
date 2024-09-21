import 'package:flutter/material.dart';
import 'package:leet_seung_mo/widgets/tag_chip.dart';

class ProblemListPage extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> problems;

  const ProblemListPage(
      {super.key, required this.title, required this.problems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: problems.length,
        itemBuilder: (context, index) {
          return ProblemListItem(problem: problems[index]);
        },
      ),
    );
  }
}

class ProblemListItem extends StatelessWidget {
  final Map<String, dynamic> problem;

  const ProblemListItem({super.key, required this.problem});

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: InkWell(
          onTap: () {
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      problem['title'] ?? 'Untitled',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(
                        problem['isFavorite'] == true
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: (problem['tags'] as List<dynamic>? ?? [])
                      .map((tag) => TagChip(label: tag.toString()))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      problem['isSolved'] == true ? 'Solved' : 'Not Solved',
                      style: TextStyle(
                        color: problem['isSolved'] == true
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (problem['isSolved'] == true &&
                        problem['solveTime'] != null)
                      Text(
                        'Time: ${problem['solveTime']}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
