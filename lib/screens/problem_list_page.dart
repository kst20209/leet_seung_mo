import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/tag_chip.dart';
import '../models/models.dart';
import '../utils/custom_network_image.dart';
import '../providers/user_data_provider.dart';

enum ProblemListType {
  problemSet, // 문제꾸러미에 속한 문제들
  incorrect, // 틀린 문제들
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
      case ProblemListType.incorrect:
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

        case ProblemListType.incorrect:
          problems = await userDataProvider.getIncorrectProblems();
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
      case ProblemListType.incorrect:
        return '틀린 문제가 없습니다';
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

class ProblemListItem extends StatefulWidget {
  final Problem problem;

  const ProblemListItem({Key? key, required this.problem}) : super(key: key);

  @override
  State<ProblemListItem> createState() => _ProblemListItemState();
}

class _ProblemListItemState extends State<ProblemListItem> {
  bool _isSolved = false;
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProblemState();
  }

  Future<void> _loadProblemState() async {
    final userDataProvider = context.read<UserDataProvider>();

    try {
      final problemData =
          await userDataProvider.getProblemData(widget.problem.id);
      if (mounted) {
        setState(() {
          _isSolved = problemData?['isSolved'] ?? false;
          _isFavorite = problemData?['isFavorite'] ?? false;
        });
      }
    } catch (e) {
      print('Error loading problem state: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userDataProvider = context.read<UserDataProvider>();
      final newState = await userDataProvider.toggleFavorite(widget.problem.id);

      if (mounted) {
        setState(() {
          _isFavorite = newState;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('즐겨찾기 설정 중 오류가 발생했습니다.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(
        _isSolved
            ? [
                0.95, 0, 0, 0, 0, // Red
                0, 0.95, 0, 0, 0, // Green
                0, 0, 0.95, 0, 0, // Blue
                0, 0, 0, 0.6, 0, // Alpha
              ]
            : [
                1, 0, 0, 0, 0, // Red
                0, 1, 0, 0, 0, // Green
                0, 0, 1, 0, 0, // Blue
                0, 0, 0, 1, 0, // Alpha
              ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/problem_solving',
              arguments: widget.problem,
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
                        imageUrl: widget.problem.imageUrl,
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
                            widget.problem.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.problem.description,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              _isFavorite ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                            ),
                      onPressed: _isLoading ? null : _toggleFavorite,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: widget.problem.tags
                      .map((tag) => TagChip(label: tag))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
