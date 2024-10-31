import 'package:flutter/material.dart';
import 'package:leet_seung_mo/widgets/tag_chip.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/user_data_provider.dart';
import '../utils/custom_network_image.dart';
import '../utils/problem_purchase_service.dart';

class ProblemSellDetail extends StatefulWidget {
  final ProblemSet problemSet;
  const ProblemSellDetail({super.key, required this.problemSet});

  @override
  State<ProblemSellDetail> createState() => _ProblemSellDetailState();
}

class _ProblemSellDetailState extends State<ProblemSellDetail> {
  final ProblemSetPurchaseService _purchaseService =
      ProblemSetPurchaseService();
  bool _isPurchasing = false;

  Future<void> _purchaseProblemSet() async {
    final authProvider = context.read<AppAuthProvider>();
    final userDataProvider = context.read<UserDataProvider>();

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    setState(() => _isPurchasing = true);

    try {
      await _purchaseService.purchaseProblemSet(
        userId: authProvider.user!.uid,
        problemSetId: widget.problemSet.id,
        problemSetTitle: widget.problemSet.title,
        price: widget.problemSet.price,
      );

      // UI 업데이트를 위해 UserDataProvider 새로고침
      await userDataProvider.refreshUserData(authProvider.user!.uid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('문제꾸러미 구매가 완료되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // 구매 완료 후 이전 화면으로 돌아가기
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isPurchasing = false);
    }
  }

  void _showPurchaseConfirmDialog(UserDataProvider userDataProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              Text(
                '문제꾸러미 구매',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Divider(),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.problemSet.title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('가격'),
                    Text(
                      '${widget.problemSet.price}P',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('보유 포인트'),
                    Text(
                      '${userDataProvider.points}P',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '구매하시겠습니까?',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '아니오',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _purchaseProblemSet();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('예'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPurchaseButton(bool isPurchased) {
    if (isPurchased) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 18),
        ),
        child: const Text(
          '구매완료',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ElevatedButton(
      onPressed: _isPurchasing
          ? null
          : () {
              final userDataProvider = context.read<UserDataProvider>();
              _showPurchaseConfirmDialog(userDataProvider);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: _isPurchasing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text('구매하기'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserDataProvider>(
        builder: (context, userDataProvider, _) {
          final purchasedSets = userDataProvider
                  .userData?['purchasedProblemSets'] as List<dynamic>? ??
              [];
          final isPurchased = purchasedSets.contains(widget.problemSet.id);
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: HeroImage(imageUrl: widget.problemSet.imageUrl),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.problemSet.title,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 8),
                      TagList(tags: widget.problemSet.tags),
                      const SizedBox(height: 16),
                      Text(
                        '총 문제 수: ${widget.problemSet.totalProblems}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.problemSet.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '가격: ${widget.problemSet.price}P',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          _buildPurchaseButton(isPurchased),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
      child: CustomNetworkImage(
        imageUrl: imageUrl,
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
