import 'package:flutter/material.dart';

class SubjectData {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> tags;

  SubjectData(this.id, this.title, this.description, this.imageUrl, this.tags);
}

class HorizontalSubjectList extends StatelessWidget {
  final List<SubjectData> subjects;

  const HorizontalSubjectList({Key? key, required this.subjects})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: subjects.asMap().entries.map((entry) {
                int index = entry.key;
                SubjectData subject = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 16 : 0,
                    right: 16,
                  ),
                  child: SizedBox(
                    width: 160,
                    child: SubjectCard(subject: subject),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class SubjectCard extends StatelessWidget {
  final SubjectData subject;

  const SubjectCard({Key? key, required this.subject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                subject.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    subject.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
