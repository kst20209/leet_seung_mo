import 'package:flutter/material.dart';
import '../widgets/section_title.dart';
import '../widgets/horizontal_subject_list.dart';
import './problem_list_page.dart';
import './problem_set_list_page.dart';
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
            recentlyAttemptedProblemIds.map((id) => problems[id]!).toList(),
          ),
          _buildSection(context, '나의 문제꾸러미', myProblemSets, isSubject: true),
          _buildSection(
            context,
            '즐겨찾기한 문제',
            favoriteProblemIds.map((id) => problems[id]!).toList(),
          ),
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                        builder: (context) => ProblemSetListPage(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProblemListPage(
                          title: title,
                          items: items.cast<Problem>(),
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
        HorizontalItemList(
          items: items.map((item) => convertToGenericItem(item)).toList(),
          onItemTap: (item) {
            if (isSubject) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProblemListPage(
                    title: item.title,
                    items: problemSetToProblems[item.id]
                            ?.map((id) => problems[id])
                            .whereType<Problem>()
                            .toList() ??
                        [],
                  ),
                ),
              );
            } else {
              Navigator.pushNamed(
                context,
                '/problem_solving',
                arguments: problems[item.id],
              );
            }
          },
        ),
      ],
    );
  }
}
