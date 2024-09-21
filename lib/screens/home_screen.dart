import 'package:flutter/material.dart';
import '../widgets/promo_banner.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> promoData = [
    {
      'imageUrl': '/api/placeholder/400/300',
      'title': 'Get a head start in 2023',
      'subtitle': 'Use code NEW YEAR for 10% off',
    },
    {
      'imageUrl': '/api/placeholder/400/300',
      'title': 'Summer Learning Challenge',
      'subtitle': 'Join now and win exciting prizes',
    },
    {
      'imageUrl': '/api/placeholder/400/300',
      'title': 'New Course: Machine Learning',
      'subtitle': 'Master AI and ML concepts',
    },
    // Add more items as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로고'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PromoBanner(bannerData: promoData),
            SectionTitle('Trending subjects'),
            HorizontalSubjectList(
              subjects: [
                SubjectData(
                    'Algebra', '1200+ problems', '/api/placeholder/200/150'),
                SubjectData(
                    'Calculus', '2200+ problems', '/api/placeholder/200/150'),
                SubjectData(
                    'Geometry', '1000+ problems', '/api/placeholder/200/150'),
              ],
            ),
            SectionTitle('New arrivals'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: SubjectCard(
                              subject: SubjectData('Physics', '1800+ problems',
                                  '/api/placeholder/150/150'))),
                      SizedBox(width: 16),
                      Expanded(
                          child: SubjectCard(
                              subject: SubjectData(
                                  'Chemistry',
                                  '2000+ problems',
                                  '/api/placeholder/150/150'))),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: SubjectCard(
                              subject: SubjectData('Biology', '2100+ problems',
                                  '/api/placeholder/150/150'),
                              isSmall: true)),
                      SizedBox(width: 16),
                      Expanded(
                          child: SubjectCard(
                              subject: SubjectData('History', '1500+ problems',
                                  '/api/placeholder/150/150'),
                              isSmall: true)),
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
    return Container(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 16 : 0, right: 16),
            child: SubjectCard(subject: subjects[index]),
          );
        },
      ),
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
  final bool isSmall;

  const SubjectCard({Key? key, required this.subject, this.isSmall = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: isSmall ? null : 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                subject.imageUrl,
                height: isSmall ? 80 : 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 4),
                  Text(
                    subject.description,
                    style: Theme.of(context).textTheme.bodyMedium,
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
