import 'package:flutter/material.dart';
import 'package:leet_seung_mo/widgets/tag_chip.dart';

class ProblemSellDetail extends StatelessWidget {
  final Map<String, dynamic> problemData;

  const ProblemSellDetail({super.key, required this.problemData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: HeroImage(imageUrl: problemData['imageUrl']),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    problemData['title'],
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  TagList(tags: problemData['tags']),
                  const SizedBox(height: 16),
                  Text(
                    '총 문제 수: ${problemData['totalProblems']}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    problemData['description'],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '가격: ${problemData['price']}P',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      BuyButton(onPressed: () {
                        // 구매 로직 구현
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeroImage extends StatelessWidget {
  final String imageUrl;

  const HeroImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: imageUrl,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }
}

class TagList extends StatelessWidget {
  final List<String> tags;

  const TagList({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: tags.map((tag) => TagChip(label: tag)).toList(),
    );
  }
}

class BuyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BuyButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: const Text('구매하기'),
    );
  }
}
