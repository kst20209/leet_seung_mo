import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/section_title.dart';
import '../widgets/horizontal_subject_list.dart';
import './problem_list_page.dart';
import './problem_set_list_page.dart';
import '../providers/user_data_provider.dart';

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
      body: Consumer<UserDataProvider>(
        builder: (context, userDataProvider, _) {
          return ListView(
            children: [
              _buildDataSection(
                context: context,
                title: '나의 문제꾸러미',
                emptyMessage: '구매한 문제꾸러미가 없습니다',
                future: userDataProvider.getPurchasedProblemSets(),
                isSubject: true,
                onMorePressed: () => _navigateToProblemSetList(context),
                onItemTap: (item, _) =>
                    _navigateToProblemSetDetail(context, item),
              ),
              _buildDataSection(
                context: context,
                title: '즐겨찾기한 문제',
                emptyMessage: '즐겨찾기한 문제가 없습니다',
                future: userDataProvider.getFavoriteProblems(),
                onMorePressed: () => _navigateToProblemList(
                  context,
                  '즐겨찾기한 문제',
                  ProblemListType.favorite,
                ),
                onItemTap: (item, items) =>
                    _navigateToProblemSolving(context, item, items),
              ),
              _buildDataSection(
                context: context,
                title: '오답노트',
                emptyMessage: '틀린 문제가 없습니다',
                future: userDataProvider.getIncorrectProblems(),
                onMorePressed: () => _navigateToProblemList(
                  context,
                  '오답노트',
                  ProblemListType.incorrect,
                ),
                onItemTap: (item, items) =>
                    _navigateToProblemSolving(context, item, items),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDataSection<T>({
    required BuildContext context,
    required String title,
    required String emptyMessage,
    required Future<List<T>> future,
    required VoidCallback onMorePressed,
    required Function(GenericItem, List<T>) onItemTap,
    bool isSubject = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title,
          onMorePressed: onMorePressed,
          padding: EdgeInsets.fromLTRB(20, 24, 4, 0),
        ),
        FutureBuilder<List<T>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
            }

            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(emptyMessage),
                ),
              );
            }
            return HorizontalItemList(
              items: items.map((item) => convertToGenericItem(item)).toList(),
              onItemTap: (item) => onItemTap(item, items),
            );
          },
        ),
      ],
    );
  }

  void _navigateToProblemList(
    BuildContext context,
    String title,
    ProblemListType type,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProblemListPage(
          title: title,
          type: type,
        ),
      ),
    );
  }

  void _navigateToProblemSetList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProblemSetListPage(),
      ),
    );
  }

  void _navigateToProblemSetDetail(BuildContext context, GenericItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProblemListPage(
          title: item.title,
          type: ProblemListType.problemSet,
          problemSetId: item.id,
        ),
      ),
    );
  }

  void _navigateToProblemSolving(
    BuildContext context,
    GenericItem item,
    List<dynamic> items,
  ) {
    Navigator.pushNamed(
      context,
      '/problem_solving',
      arguments: items.firstWhere((p) => p.id == item.id),
    );
  }
}
