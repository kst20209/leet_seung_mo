import 'package:flutter/material.dart';
import '../widgets/tag_chip.dart';
import '../widgets/horizontal_subject_list.dart';
import './problem_data.dart';

class ProblemListPage extends StatelessWidget {
  final String title;
  final List<dynamic> items;

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
          return GenericListItem(item: item);
        },
      ),
    );
  }
}

class GenericListItem extends StatelessWidget {
  final dynamic item;

  const GenericListItem({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isProblem = item is ProblemData;
    final String title =
        isProblem ? (item as ProblemData).title : (item as SubjectData).title;
    final String description = isProblem
        ? (item as ProblemData).description
        : (item as SubjectData).description;
    final String imageUrl = isProblem
        ? (item as ProblemData).imageUrl
        : (item as SubjectData).imageUrl;
    final List<String> tags =
        isProblem ? (item as ProblemData).tags : (item as SubjectData).tags;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          if (isProblem) {
            Navigator.pushNamed(
              context,
              '/problem_solving',
              arguments: item as ProblemData,
            );
          } else {
            // Navigate to problem list for this subject
            // This part remains unchanged
          }
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
                      imageUrl,
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
                          title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          description,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  if (isProblem)
                    IconButton(
                      icon: Icon(
                        (item as ProblemData).isFavorite
                            ? Icons.star
                            : Icons.star_border,
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
                children: tags.map((tag) => TagChip(label: tag)).toList(),
              ),
              if (isProblem) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (item as ProblemData).isSolved ? 'Solved' : 'Not Solved',
                      style: TextStyle(
                        color: (item as ProblemData).isSolved
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if ((item as ProblemData).isSolved &&
                        (item as ProblemData).solveTime != null)
                      Text(
                        'Time: ${(item as ProblemData).solveTime}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
