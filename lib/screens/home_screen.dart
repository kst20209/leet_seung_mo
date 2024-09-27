import 'package:flutter/material.dart';
import '../widgets/promo_banner.dart';
import '../widgets/section_title.dart';
import '../widgets/horizontal_subject_list.dart';
import '../screens/problem_data.dart';
import '../screens/problem_solving_page.dart';
import '../screens/problem_list_page.dart';
import '../models/models.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> promoData = [
    {
      'imageUrl':
          'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/Thumbnail1.png?alt=media&token=03a39d6d-35dd-495f-8533-6e5171fed942',
      'title': '리승모 론칭 이벤트!',
      'subtitle': '상점에서 포인트를 할인받고 구입하세요',
    },
    {
      'imageUrl':
          'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/Thumbnail3.png?alt=media&token=c01bbb55-145d-4af9-819c-2735d03f997b',
      'title': '새 무료 문제 도착',
      'subtitle': '새로 도착한 무료 문제를 확인하세요',
    },
    {
      'imageUrl':
          'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/stars_lily.png?alt=media&token=262dc9d5-7838-43b6-815c-5f2714ca8c29',
      'title': '별점 이벤트',
      'subtitle': '앱 스토어에 평가를 남기고 무료 포인트 받아가세요!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('리승모'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PromoBanner(bannerData: promoData),
            SectionTitle('풀던 문제 바로가기'),
            HorizontalItemList(
              items: recentlyAttemptedProblemIds
                  .map((id) => convertToGenericItem(problems[id]!))
                  .toList(),
              onItemTap: (item) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProblemSolvingPage(
                      problem: problems[item.id]!,
                    ),
                  ),
                );
              },
            ),
            SectionTitle('오늘의 무료 문제'),
            HorizontalItemList(
              items: freeProblemToday.map(convertToGenericItem).toList(),
              onItemTap: (item) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProblemSolvingPage(
                      problem:
                          freeProblemToday.firstWhere((p) => p.id == item.id),
                    ),
                  ),
                );
              },
            ),
            SectionTitle('추천 문제꾸러미'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  for (int i = 0; i < recommendedProblemSets.length; i += 2)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildProblemSetCard(
                                context, recommendedProblemSets[i]),
                          ),
                          if (i + 1 < recommendedProblemSets.length) ...[
                            SizedBox(width: 10),
                            Expanded(
                              child: _buildProblemSetCard(
                                  context, recommendedProblemSets[i + 1]),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemSetCard(BuildContext context, ProblemSet problemSet) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProblemListPage(
                title: problemSet.title,
                items: problemSetToProblems[problemSet.id]
                        ?.map((id) => problems[id])
                        .whereType<Problem>()
                        .toList() ??
                    [],
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              child: Image.network(
                problemSet.imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    problemSet.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    problemSet.description,
                    style: TextStyle(color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
