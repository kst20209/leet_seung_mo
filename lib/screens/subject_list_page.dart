import 'package:flutter/material.dart';
import './problem_list_page.dart';
import './problem_data.dart';

class SubjectListPage extends StatelessWidget {
  const SubjectListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('과목 목록'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: myProblems.length,
        itemBuilder: (context, index) {
          final subject = myProblems[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  subject.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(subject.title),
              subtitle: Text(subject.description),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProblemListPage(
                      title: subject.title,
                      items: subjectToProblemIds[subject.id]
                              ?.map((id) => allProblems[id])
                              .whereType<ProblemData>()
                              .toList() ??
                          [],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
