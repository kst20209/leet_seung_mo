import 'package:flutter/material.dart';
import 'package:leet_seung_mo/utils/sort_service.dart';
import 'package:provider/provider.dart';
import '../widgets/section_title.dart';
import '../widgets/horizontal_subject_list.dart';
import './problem_list_page.dart';
import './problem_set_list_page.dart';
import '../providers/user_data_provider.dart';

class MyProblemPage extends StatefulWidget {
  const MyProblemPage({Key? key}) : super(key: key);

  @override
  State<MyProblemPage> createState() => _MyProblemPageState();
}

class _MyProblemPageState extends State<MyProblemPage> {
  late final VoidCallback listener;
  UserDataProvider? _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider 참조를 안전하게 저장
    _provider = context.read<UserDataProvider>();
  }

  @override
  void initState() {
    super.initState();
    // 컴포넌트가 마운트될 때 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      listener = () {
        if (_provider?.error != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_provider!.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      };
      // 저장된 리스너 함수를 추가
      _provider?.addListener(listener);
      _provider?.loadAllProblemData();
    });
  }

  @override
  void dispose() {
    _provider?.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 문제'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<UserDataProvider>().loadAllProblemData(),
        child: Consumer<UserDataProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingProblems) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              children: [
                _buildDataSection(
                  context: context,
                  title: '나의 문제꾸러미',
                  icon: Icons.collections_bookmark,
                  emptyMessage: '구매한 문제꾸러미가 없습니다',
                  items: SortService()
                      .sortProblemSets(provider.purchasedProblemSets),
                  isSubject: true,
                  onMorePressed: () => _navigateToProblemSetList(context),
                  onItemTap: (item, _) =>
                      _navigateToProblemSetDetail(context, item),
                ),
                _buildDataSection(
                  context: context,
                  title: '즐겨찾기한 문제',
                  icon: Icons.star_rounded,
                  emptyMessage: '즐겨찾기한 문제가 없습니다',
                  items: SortService().sortProblems(provider.favoriteProblems),
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
                  items: SortService().sortProblems(provider.incorrectProblems),
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildDataSection<T>({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String emptyMessage,
    required List<T> items,
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
          padding: const EdgeInsets.fromLTRB(20, 16, 4, 0),
        ),
        if (items.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Text(emptyMessage),
            ),
          )
        else
          HorizontalItemList(
            items: items.map((item) => convertToGenericItem(item)).toList(),
            onItemTap: (item) => onItemTap(item, items),
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
