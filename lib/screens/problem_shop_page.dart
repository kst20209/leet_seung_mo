import 'package:flutter/material.dart';
import 'package:leet_seung_mo/widgets/tag_chip.dart';
import '../widgets/problem_item.dart';

class ProblemShopPage extends StatefulWidget {
  const ProblemShopPage({super.key});

  @override
  _ProblemShopPageState createState() => _ProblemShopPageState();
}

class _ProblemShopPageState extends State<ProblemShopPage> {
  bool _isFilterExpanded = false;
  List<Map<String, dynamic>> _problems = [];

  @override
  void initState() {
    super.initState();
    _fetchProblems();
  }

  void _fetchProblems() {
    setState(() {
      _problems = [
        {
          'id': '1',
          'title': '자연과학 복합형 꾸러미 1',
          'tags': ['복합형', '자연과학'],
          'price': 500,
          'imageUrl':
              'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/Thumbnail1.png?alt=media&token=03a39d6d-35dd-495f-8533-6e5171fed942',
        },
        {
          'id': '2',
          'title': '사회과학 추론형 꾸러미 1',
          'tags': ['추론형', '사회과학'],
          'price': 500,
          'imageUrl':
              'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/Thumbnail1.png?alt=media&token=03a39d6d-35dd-495f-8533-6e5171fed942',
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('문제 상점'),
        elevation: 0,
      ),
      body: Column(
        children: [
          FilterSection(
            isExpanded: _isFilterExpanded,
            onExpandToggle: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _problems.length,
              itemBuilder: (context, index) {
                return ProblemItem(problemData: _problems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilterSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onExpandToggle;

  const FilterSection({
    Key? key,
    required this.isExpanded,
    required this.onExpandToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '필터',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon:
                      Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: onExpandToggle,
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilterGroup(title: '과목', filters: ['추리논증', '언어이해']),
                  const SizedBox(height: 16),
                  FilterGroup(
                    title: '유형',
                    filters: [
                      '단순주장형',
                      '논쟁형',
                      '결과분석형',
                      '규정해석형',
                      '지문분석형',
                      '사례분석형',
                      '규정적용형',
                      '다이어그램형',
                      '퀴즈형'
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilterGroup(
                      title: '주제',
                      filters: ['법학', '순수학문', '사회학문', '자연과학', '기타학문']),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FilterGroup extends StatelessWidget {
  final String title;
  final List<String> filters;

  const FilterGroup({Key? key, required this.title, required this.filters})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filters
              .map((filter) => TagChip(
                    label: filter,
                    onTap: () {
                      // TODO: 필터 선택 로직 구현
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }
}
