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

  // Firestore에서 데이터를 가져오는 것을 시뮬레이션하는 메서드
  void _fetchProblems() {
    // 실제로는 여기서 Firestore 쿼리를 수행합니다.
    // 지금은 더미 데이터로 시뮬레이션합니다.
    setState(() {
      _problems = [
        {
          'id': '1',
          'title': '자연과학 복합형 꾸러미 1',
          'tags': ['복합형', '자연과학'],
          'price': 500,
          'imageUrl': 'https://via.placeholder.com/150',
          'totalProblems': 50,
          'description':
              '이 문제 꾸러미는 자연과학 분야의 복합적인 문제들로 구성되어 있습니다. 물리, 화학, 생물학 등 다양한 주제를 다루며, 실제 시험에서 나올 수 있는 난이도의 문제들을 포함하고 있습니다.',
        },
        {
          'id': '2',
          'title': '사회과학 추론형 꾸러미 1',
          'tags': ['추론형', '사회과학'],
          'price': 500,
          'imageUrl': 'https://via.placeholder.com/150',
          'totalProblems': 50,
          'description': '이 문제 꾸러미는 사회과학 분야의 복합적인 문제들로 구성되어 있습니다.',
        },
        // 추가 문제 데이터...
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('문제 상점'),
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

  const FilterSection(
      {super.key, required this.isExpanded, required this.onExpandToggle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('필터',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: onExpandToggle,
            ),
          ],
        ),
        if (isExpanded) ...[
          const FilterGroup(title: '과목', filters: ['추리논증', '언어이해']),
          const FilterGroup(
              title: '유형', filters: ['추론형', '결과분석형', '귀결적', '단순추정형', '다이어그램형']),
          const FilterGroup(title: '주제', filters: ['법학', '사회과학', '경제학']),
        ],
      ],
    );
  }
}

class FilterGroup extends StatelessWidget {
  final String title;
  final List<String> filters;

  const FilterGroup({super.key, required this.title, required this.filters});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: filters
              .map((filter) => TagChip(
                    label: filter,
                    onTap: () {
                      // 필터 선택 로직 구현
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }
}
