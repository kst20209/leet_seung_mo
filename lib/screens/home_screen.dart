import 'package:flutter/material.dart';
import '../widgets/promo_banner.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> promoData = [
    {
      'imageUrl':
          'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/Thumbnail1.png?alt=media&token=03a39d6d-35dd-495f-8533-6e5171fed942',
      'title': 'Get a head start in 2023',
      'subtitle': 'Use code NEW YEAR for 10% off',
    },
    // {
    //   'imageUrl': '/api/placeholder/400/300',
    //   'title': 'Summer Learning Challenge',
    //   'subtitle': 'Join now and win exciting prizes',
    // },
    // {
    //   'imageUrl': '/api/placeholder/400/300',
    //   'title': 'New Course: Machine Learning',
    //   'subtitle': 'Master AI and ML concepts',
    // },
    // Add more items as needed
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
            HorizontalSubjectList(
              subjects: [
                SubjectData('4번', '추리논증 단순주장+논쟁형 기타',
                    'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A8%EC%88%9C%EC%A3%BC%EC%9E%A5.png?alt=media&token=5662465b-8be8-44a9-bb5e-fbf5a5aee41b'),
                SubjectData('3번', '추리논증 단순주장+논쟁형 기타',
                    'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A8%EC%88%9C%EC%A3%BC%EC%9E%A5.png?alt=media&token=5662465b-8be8-44a9-bb5e-fbf5a5aee41b'),
                SubjectData('2번', '추리논증 단순주장+논쟁형 기타',
                    'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A8%EC%88%9C%EC%A3%BC%EC%9E%A5.png?alt=media&token=5662465b-8be8-44a9-bb5e-fbf5a5aee41b'),
              ],
            ),
            SectionTitle('오늘의 무료 문제'),
            HorizontalSubjectList(
              subjects: [
                SubjectData('추리논증', '다이어그램형',
                    'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A4%EC%9D%B4%EC%96%B4%EA%B7%B8%EB%9E%A8%ED%98%95.png?alt=media&token=2e1290bf-f6c9-403c-bb70-ac270718e6e0'),
                SubjectData('추리논증', '논쟁형',
                    'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%85%BC%EC%9F%81%ED%98%95.png?alt=media&token=e88eb6a5-d88b-46d9-93a5-21feb5fcc124'),
                SubjectData('언어이해', '자료분석형',
                    'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EC%B0%A8%ED%8A%B8%ED%98%95.png?alt=media&token=dcb2f00f-c669-4f4d-8e1b-e2d2dea860b4'),
              ],
            ),
            SectionTitle('인기 문제꾸러미'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: SubjectCard(
                              subject: SubjectData('추리논증 결과분석형', '자연과학 문제꾸러미',
                                  'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/Thumbnail1.png?alt=media&token=03a39d6d-35dd-495f-8533-6e5171fed942'))),
                      SizedBox(width: 16),
                      Expanded(
                          child: SubjectCard(
                              subject: SubjectData('추리논증 규정해석형', '특이유형 문제꾸러미',
                                  'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%AC%B8%EC%A0%9C1.png?alt=media&token=fa06bb0d-4b2e-44be-a27f-a061e13c475d'))),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: SubjectCard(
                        subject: SubjectData('추리논증 퀴즈형', '논리퀴즈 복합형',
                            'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%AC%B8%EC%A0%9C2.png?alt=media&token=ad8f8f39-d3df-4193-912d-b6a1e646e431'),
                      )),
                      SizedBox(width: 16),
                      Expanded(
                          child: SubjectCard(
                        subject: SubjectData('추리논증 단순주장+논쟁형', '순수학문 문제꾸러미',
                            'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%AC%B8%EC%A0%9C3.png?alt=media&token=ad1f8072-9b30-435d-9a7c-c977f184ac3a'),
                      )),
                    ],
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
}

class HeroImage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;

  const HeroImage({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class HorizontalSubjectList extends StatelessWidget {
  final List<SubjectData> subjects;

  const HorizontalSubjectList({Key? key, required this.subjects})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: subjects.asMap().entries.map((entry) {
                int index = entry.key;
                SubjectData subject = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 16 : 0,
                    right: 16,
                  ),
                  child: SizedBox(
                    width: 160,
                    child: SubjectCard(subject: subject),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class SubjectData {
  final String title;
  final String description;
  final String imageUrl;

  SubjectData(this.title, this.description, this.imageUrl);
}

class SubjectCard extends StatelessWidget {
  final SubjectData subject;

  const SubjectCard({Key? key, required this.subject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                subject.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0),
                  Text(
                    subject.description,
                    style: Theme.of(context).textTheme.bodyMedium,
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
