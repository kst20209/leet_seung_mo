import 'package:flutter/material.dart';
import 'package:leet_seung_mo/providers/auth_provider.dart';
import 'package:leet_seung_mo/utils/responsive_container.dart';
import 'package:leet_seung_mo/utils/sort_service.dart';
import 'package:provider/provider.dart';
import '../widgets/tag_chip.dart';
import './problem_list_page.dart';
import '../utils/custom_network_image.dart';
import '../models/models.dart';
import '../providers/user_data_provider.dart';

class ProblemSetListPage extends StatefulWidget {
  const ProblemSetListPage({Key? key}) : super(key: key);

  @override
  State<ProblemSetListPage> createState() => _ProblemSetListPageState();
}

class _ProblemSetListPageState extends State<ProblemSetListPage> {
  List<ProblemSet>? _problemSets;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProblemSets();
  }

  Future<void> _loadProblemSets() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final userDataProvider = context.read<UserDataProvider>();
      final authProvider = context.read<AppAuthProvider>();

      // 먼저 전체 데이터 새로고침
      await userDataProvider.refreshUserData(authProvider.user!.uid);

      final problemSets =
          await context.read<UserDataProvider>().getPurchasedProblemSets();

      if (mounted) {
        setState(() {
          _problemSets = SortService().sortProblemSets(problemSets);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

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
      body: ResponsiveContainer(
        child: RefreshIndicator(
          onRefresh: _loadProblemSets,
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('오류가 발생했습니다: $_error'),
            ElevatedButton(
              onPressed: _loadProblemSets,
              child: Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_problemSets?.isEmpty ?? true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '구매한 문제꾸러미가 없습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _problemSets!.length,
      itemBuilder: (context, index) {
        final problemSet = _problemSets![index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: PurchasedProblemSetItem(
            problemSet: problemSet,
            // totalSolvedProblems: problemSet.solvedProblems, // 데이터가 있다면 추가
          ),
        );
      },
    );
  }
}

class PurchasedProblemSetItem extends StatelessWidget {
  final ProblemSet problemSet;
  final int? totalSolvedProblems; // 선택적으로 추가할 수 있는 정보

  const PurchasedProblemSetItem({
    Key? key,
    required this.problemSet,
    this.totalSolvedProblems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProblemListPage(
                title: problemSet.title,
                type: ProblemListType.problemSet,
                problemSetId: problemSet.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomNetworkImage(
                    imageUrl: problemSet.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      problemSet.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: problemSet.tags
                          .map((tag) => TagChip(label: tag))
                          .toList(),
                    ),
                    SizedBox(height: 4),
                    if (totalSolvedProblems != null)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          '${totalSolvedProblems}/${problemSet.totalProblems} 문제 해결',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
