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
          'tags': ['추리논증', '복합형', '자연과학'],
          'price': 500,
          'imageUrl':
              'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/Thumbnail1.png?alt=media&token=03a39d6d-35dd-495f-8533-6e5171fed942',
          'totalProblems': 15,
          'description': '자연과학 복합형 문제를 모았습니다.'
        },
        {
          'id': '2',
          'title': '사회과학 추론형 꾸러미 1',
          'tags': ['추리논증', '추론형', '사회과학'],
          'price': 500,
          'imageUrl':
              'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/Thumbnail1.png?alt=media&token=03a39d6d-35dd-495f-8533-6e5171fed942',
          'totalProblems': 15,
          'description': '사회과학 추론형 문제를 모았습니다.'
        },
        {
          'id': '3',
          'title': '추리논증 다이어그램형 문제꾸러미 1',
          'tags': ["추리논증", "다이어그램형"],
          'price': 500,
          'imageUrl':
              'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A4%EC%9D%B4%EC%96%B4%EA%B7%B8%EB%9E%A8%ED%98%95.png?alt=media&token=2e1290bf-f6c9-403c-bb70-ac270718e6e0',
          'totalProblems': 10,
          'description': '추리논증 다이어그램형 문제를 모았습니다.'
        },
        {
          'id': '4',
          'title': '추리논증 논쟁형 복합형 문제꾸러미',
          'tags': ["추리논증", "논쟁형", "복합형"],
          'price': 500,
          'imageUrl':
              'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%85%BC%EC%9F%81%ED%98%95.png?alt=media&token=e88eb6a5-d88b-46d9-93a5-21feb5fcc124',
          'totalProblems': 15,
          'description': '논쟁형 복합형 문제를 모았습니다.'
        },
        {
          'id': '5',
          'title': '추리논증 결과분석형 자연과학 문제꾸러미',
          'tags': ["추리논증", "결과분석형", "자연과학"],
          'price': 500,
          'imageUrl':
              'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EC%B0%A8%ED%8A%B8%ED%98%95.png?alt=media&token=dcb2f00f-c669-4f4d-8e1b-e2d2dea860b4',
          'totalProblems': 15,
          'description': '자연과학 결과분석형 문제를 모았습니다.'
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
                    onTap: () {},
                  ))
              .toList(),
        ),
      ],
    );
  }
}
