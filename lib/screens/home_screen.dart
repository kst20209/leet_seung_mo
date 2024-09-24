import 'package:flutter/material.dart';
import '../widgets/promo_banner.dart';
import '../widgets/section_title.dart';
import '../widgets/horizontal_subject_list.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> promoData = [
    {
      'imageUrl':
          'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/Thumbnail1.png?alt=media&token=03a39d6d-35dd-495f-8533-6e5171fed942',
      'title': 'Get a head start in 2023',
      'subtitle': 'Use code NEW YEAR for 10% off',
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
            HorizontalSubjectList(
              subjects: [
                SubjectData(
                    '1',
                    '4번',
                    '추리논증 단순주장+논쟁형 기타',
                    'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A8%EC%88%9C%EC%A3%BC%EC%9E%A5.png?alt=media&token=5662465b-8be8-44a9-bb5e-fbf5a5aee41b',
                    ['추리논증', '단순주장', '논쟁형']),
                SubjectData(
                    '1',
                    '3번',
                    '추리논증 단순주장+논쟁형 기타',
                    'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A8%EC%88%9C%EC%A3%BC%EC%9E%A5.png?alt=media&token=5662465b-8be8-44a9-bb5e-fbf5a5aee41b',
                    ['추리논증', '단순주장', '논쟁형']),
                SubjectData(
                    '1',
                    '2번',
                    '추리논증 단순주장+논쟁형 기타',
                    'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A8%EC%88%9C%EC%A3%BC%EC%9E%A5.png?alt=media&token=5662465b-8be8-44a9-bb5e-fbf5a5aee41b',
                    ['추리논증', '단순주장', '논쟁형']),
              ],
            ),
            SectionTitle('오늘의 무료 문제'),
            HorizontalSubjectList(
              subjects: [
                SubjectData(
                    '1',
                    '추리논증',
                    '다이어그램형',
                    'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A4%EC%9D%B4%EC%96%B4%EA%B7%B8%EB%9E%A8%ED%98%95.png?alt=media&token=2e1290bf-f6c9-403c-bb70-ac270718e6e0',
                    ['추리논증', '다이어그램형']),
                SubjectData(
                    '1',
                    '추리논증',
                    '논쟁형',
                    'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%85%BC%EC%9F%81%ED%98%95.png?alt=media&token=e88eb6a5-d88b-46d9-93a5-21feb5fcc124',
                    ['추리논증', '논쟁형']),
                SubjectData(
                    '1',
                    '언어이해',
                    '자료분석형',
                    'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EC%B0%A8%ED%8A%B8%ED%98%95.png?alt=media&token=dcb2f00f-c669-4f4d-8e1b-e2d2dea860b4',
                    ['언어이해', '자료분석형']),
              ],
            ),
            SectionTitle('추천 문제꾸러미'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: SubjectCard(
                              subject: SubjectData(
                                  '1',
                                  '추리논증 결과분석형',
                                  '자연과학 문제꾸러미',
                                  'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/Thumbnail1.png?alt=media&token=03a39d6d-35dd-495f-8533-6e5171fed942',
                                  ['추리논증', '결과분석형', '자연과학']))),
                      SizedBox(width: 10),
                      Expanded(
                          child: SubjectCard(
                              subject: SubjectData(
                                  '1',
                                  '추리논증 규정해석형',
                                  '특이유형 문제꾸러미',
                                  'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%AC%B8%EC%A0%9C1.png?alt=media&token=fa06bb0d-4b2e-44be-a27f-a061e13c475d',
                                  ['추리논증', '규정해석형', '특이유형']))),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: SubjectCard(
                        subject: SubjectData(
                            '1',
                            '추리논증 퀴즈형',
                            '논리퀴즈 복합형',
                            'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%AC%B8%EC%A0%9C2.png?alt=media&token=ad8f8f39-d3df-4193-912d-b6a1e646e431',
                            ['추리논증', '퀴즈형', '논리퀴즈']),
                      )),
                      SizedBox(width: 10),
                      Expanded(
                          child: SubjectCard(
                        subject: SubjectData(
                            '1',
                            '추리논증 단순주장+논쟁형',
                            '순수학문 문제꾸러미',
                            'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%AC%B8%EC%A0%9C3.png?alt=media&token=ad1f8072-9b30-435d-9a7c-c977f184ac3a',
                            ['추리논증', '단순주장', '논쟁형', '순수학문']),
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
