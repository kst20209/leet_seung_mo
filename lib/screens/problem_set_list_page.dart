import 'package:flutter/material.dart';
import './problem_list_page.dart';
import '../utils/problem_data.dart';
import '../models/models.dart';

class ProblemSetListPage extends StatelessWidget {
  const ProblemSetListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('문제꾸러미 목록'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: myProblemSets.length,
        itemBuilder: (context, index) {
          final problemSet = myProblemSets[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  problemSet.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(problemSet.title),
              subtitle: Text(problemSet.description),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProblemListPage(
                      title: problemSet.title,
                      items: problemSetToProblems[problemSet.id]
                              ?.map((id) => problems[id])
                              .whereType<Problem>()
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
