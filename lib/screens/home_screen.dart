import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_data_provider.dart';
import '../widgets/promo_banner.dart';
import '../widgets/section_title.dart';
import '../widgets/horizontal_subject_list.dart';
import '../screens/problem_solving_page.dart';
import '../screens/problem_list_page.dart';
import '../models/models.dart';
import '../utils/home_data_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeDataService _homeDataService = HomeDataService();

  Future<void> _handlePromotionTap(Map<String, dynamic> promoBanners) async {
    _homeDataService.handlePromotionAction(context, promoBanners['action']);
  }

  Widget _buildDataSection<T>({
    required String title,
    required IconData icon,
    required Future<List<T>> future,
    required Function(GenericItem, List<T>) onItemTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: SectionTitle(
            title,
            icon: icon,
            padding: EdgeInsets.fromLTRB(20, 24, 0, 8),
          ),
        ),
        FutureBuilder<List<T>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
            }

            final items = snapshot.data ?? [];
            return HorizontalItemList(
              items: items.map((item) => convertToGenericItem(item)).toList(),
              onItemTap: (item) => onItemTap(item, items),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPurchasedProblemSets() {
    return Consumer<UserDataProvider>(
      builder: (context, userDataProvider, _) {
        return _buildDataSection<ProblemSet>(
          title: '나의 문제꾸러미',
          icon: Icons.collections_bookmark,
          future: userDataProvider
              .getPurchasedProblemSets(), // watch를 통한 Provider 사용
          onItemTap: (item, items) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProblemListPage(
                  title: item.title,
                  type: ProblemListType.problemSet,
                  problemSetId: item.id,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/logo.svg',
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
              height: AppBar.preferredHeightFor(
                      context, Size.fromHeight(kToolbarHeight)) *
                  0.35,
              fit: BoxFit.contain,
            ),
            // SizedBox(width: 6),
            // const Text('리승모'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {}); // 전체 화면 새로고침
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _homeDataService.getActivePromotions(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('배너를 불러올 수 없습니다.'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return PromoBanner(
                    bannerData: snapshot.data!,
                    onTap: _handlePromotionTap,
                  );
                },
              ),
              _buildDataSection<Problem>(
                title: '오늘의 무료 문제',
                icon: Icons.local_offer,
                future: _homeDataService.getTodayFreeProblems(),
                onItemTap: (item, items) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProblemSolvingPage(
                        problem: items.firstWhere((p) => p.id == item.id),
                      ),
                    ),
                  );
                },
              ),
              _buildPurchasedProblemSets(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
