import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/section_title.dart';
import '../widgets/horizontal_subject_list.dart';
import './problem_list_page.dart';
import './problem_set_list_page.dart';
import '../providers/user_data_provider.dart';
import '../models/models.dart';

class MyProblemPage extends StatefulWidget {
  const MyProblemPage({Key? key}) : super(key: key);

  @override
  State<MyProblemPage> createState() => _MyProblemPageState();
}

class _MyProblemPageState extends State<MyProblemPage> {
  Future<List<ProblemSet>>? problemSetsFuture;
  Future<List<Problem>>? favoritesFuture;
  Future<List<Problem>>? incorrectFuture;

  @override
  void initState() {
    super.initState();
    _initializeFutures();
  }

  void _initializeFutures() {
    final userDataProvider = context.read<UserDataProvider>();
    if (userDataProvider.status == UserDataStatus.loaded) {
      _loadFutures();
    } else {
      userDataProvider.addListener(_onUserDataLoaded);
    }
  }

  void _onUserDataLoaded() {
    final userDataProvider = context.read<UserDataProvider>();
    if (userDataProvider.status == UserDataStatus.loaded) {
      _loadFutures();
      userDataProvider.removeListener(_onUserDataLoaded);
    }
  }

  void _loadFutures() {
    final userDataProvider = context.read<UserDataProvider>();
    setState(() {
      problemSetsFuture = userDataProvider.getPurchasedProblemSets();
      favoritesFuture = userDataProvider.getFavoriteProblems();
      incorrectFuture = userDataProvider.getIncorrectProblems();
    });
  }

  @override
  void dispose() {
    context.read<UserDataProvider>().removeListener(_onUserDataLoaded);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 문제'),
      ),
      body: ListView(
        children: [
          _buildDataSection(
            context: context,
            title: '나의 문제꾸러미',
            icon: Icons.collections_bookmark,
            emptyMessage: '구매한 문제꾸러미가 없습니다',
            future: problemSetsFuture ?? Future.value([]),
            isSubject: true,
            onMorePressed: () => _navigateToProblemSetList(context),
            onItemTap: (item, _) => _navigateToProblemSetDetail(context, item),
          ),
          _buildDataSection(
            context: context,
            title: '즐겨찾기한 문제',
            icon: Icons.star_rounded,
            emptyMessage: '즐겨찾기한 문제가 없습니다',
            future: favoritesFuture ?? Future.value([]),
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
            icon: Icons.rate_review,
            emptyMessage: '틀린 문제가 없습니다',
            future: incorrectFuture ?? Future.value([]),
            onMorePressed: () => _navigateToProblemList(
              context,
              '오답노트',
              ProblemListType.incorrect,
            ),
            onItemTap: (item, items) =>
                _navigateToProblemSolving(context, item, items),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDataSection<T>({
    required BuildContext context,
    required String title,
    required IconData icon,
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
          icon: icon,
          onMorePressed: onMorePressed,
          padding: const EdgeInsets.fromLTRB(20, 24, 4, 0),
        ),
        FutureBuilder<List<T>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
            }

            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
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
        builder: (context) => const ProblemSetListPage(),
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
