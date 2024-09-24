import 'package:flutter/material.dart';
import '../widgets/section_title.dart';
import '../widgets/horizontal_subject_list.dart';
import './problem_list_page.dart';
import './subject_list_page.dart';
import './problem_data.dart';

class MyProblemPage extends StatelessWidget {
  MyProblemPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 문제'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildSection(
              context,
              '풀던 문제',
              recentlyAttemptedProblemIds
                  .map((id) => allProblems[id]!)
                  .toList()),
          _buildSection(context, '나의 문제꾸러미', myProblems, isSubject: true),
          _buildSection(context, '즐겨찾기한 문제',
              favoriteProblemIds.map((id) => allProblems[id]!).toList()),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<dynamic> items,
      {bool isSubject = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SectionTitle(title),
              TextButton(
                onPressed: () {
                  if (isSubject) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubjectListPage(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProblemListPage(
                          title: title,
                          items: items,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('더보기'),
              ),
            ],
          ),
        ),
        HorizontalSubjectList(
          subjects: items.map((item) {
            if (item is ProblemData) {
              return SubjectData(
                item.id,
                item.title,
                item.description,
                item.imageUrl,
                item.tags,
              );
            } else if (item is SubjectData) {
              return item;
            }
            throw ArgumentError('Invalid item type');
          }).toList(),
        ),
      ],
    );
  }
}
