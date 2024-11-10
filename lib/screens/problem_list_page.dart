import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/tag_chip.dart';
import '../models/models.dart';
import '../utils/custom_network_image.dart';
import '../providers/user_data_provider.dart';

enum ProblemListType {
  problemSet, // 문제꾸러미에 속한 문제들
  recentlySolved, // 최근 푼 문제들
  favorite, // 즐겨찾기한 문제들
}

class ProblemListPage extends StatefulWidget {
  final String title;
  final ProblemListType? type;
  final String? problemSetId; // Optional, only needed for problemSet type
  final List<Problem>? initialProblems; // Optional, can be provided directly

  const ProblemListPage({
    Key? key,
    required this.title,
    this.type,
    this.problemSetId,
    this.initialProblems,
  }) : super(key: key);

  @override
  State<ProblemListPage> createState() => _ProblemListPageState();
}

class _ProblemListPageState extends State<ProblemListPage> {
  List<Problem>? _problems;
  bool _isLoading = true;
  String? _error;

  // 제목에서 숫자 추출하는 함수
  int _extractNumber(String title) {
    // 정규식을 사용하여 숫자만 추출
    final numStr = title.replaceAll(RegExp(r'[^0-9]'), '');
    if (numStr.isEmpty) return 0;
    return int.parse(numStr);
  }

  List<Problem> _sortProblems(List<Problem> problems) {
    switch (widget.type ?? ProblemListType.favorite) {
      case ProblemListType.problemSet:
        // 제목의 숫자를 기준으로 정렬
        return List.from(problems)
          ..sort((a, b) =>
              _extractNumber(a.title).compareTo(_extractNumber(b.title)));
      case ProblemListType.recentlySolved:
        // 최근 푼 문제는 현재 순서 유지
        return problems;
      case ProblemListType.favorite:
        // 즐겨찾기도 제목의 숫자 기준으로 정렬
        return List.from(problems)
          ..sort((a, b) =>
              _extractNumber(a.title).compareTo(_extractNumber(b.title)));
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialProblems != null) {
      _problems = widget.initialProblems;
      _isLoading = false;
    } else {
      _loadProblems();
    }
  }

  Future<void> _loadProblems() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final userDataProvider = context.read<UserDataProvider>();
      List<Problem> problems;

      switch (widget.type ?? ProblemListType.favorite) {
        case ProblemListType.problemSet:
          if (widget.problemSetId == null) {
            throw Exception('problemSetId is required for problemSet type');
          }
          problems = await userDataProvider
              .getProblemsByProblemSetId(widget.problemSetId!);
          problems = _sortProblems(problems);
          break;

        case ProblemListType.recentlySolved:
          problems = await userDataProvider.getRecentlySolvedProblems();
          problems = _sortProblems(problems);
          break;

        case ProblemListType.favorite:
          problems = await userDataProvider.getFavoriteProblems();
          problems = _sortProblems(problems);
          break;
      }

      if (mounted) {
        setState(() {
          _problems = problems;
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

  String get _emptyStateMessage {
    switch (widget.type ?? ProblemListType.favorite) {
      case ProblemListType.problemSet:
        return '문제꾸러미에 문제가 없습니다';
      case ProblemListType.recentlySolved:
        return '최근 푼 문제가 없습니다';
      case ProblemListType.favorite:
        return '즐겨찾기한 문제가 없습니다';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProblems,
        child: _buildContent(),
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
              onPressed: _loadProblems,
              child: Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_problems?.isEmpty ?? true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              _emptyStateMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _problems!.length,
      itemBuilder: (context, index) {
        final problem = _problems![index];
        return ProblemListItem(problem: problem);
      },
    );
  }
}

class ProblemListItem extends StatelessWidget {
  final Problem problem;

  const ProblemListItem({Key? key, required this.problem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 하드코딩된 값들
    final bool isSolved = false;
    final String solveTime = '5분 30초';
    final bool isFavorite = true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/problem_solving',
            arguments: problem,
          );
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
                    child: CustomNetworkImage(
                      imageUrl: problem.imageUrl,
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
                          problem.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          problem.description,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
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
                children:
                    problem.tags.map((tag) => TagChip(label: tag)).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSolved ? 'Solved' : 'Not Solved',
                    style: TextStyle(
                      color: isSolved ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isSolved)
                    Text(
                      'Time: $solveTime',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
