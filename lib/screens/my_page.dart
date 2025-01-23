import 'package:flutter/material.dart';
import 'package:leet_seung_mo/utils/responsive_container.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import './mypage/change_phone_screen.dart';
import 'mypage/inquiry_page.dart';
import 'mypage/point_transaction_history_page.dart';

import '../providers/user_data_provider.dart';
import 'purchase_point_page.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late Map<String, dynamic> userData;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await context.read<AppAuthProvider>().signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마이페이지'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(context),
              SizedBox(height: 16),
              _buildPointCard(context),
              Divider(height: 32),
              _buildStatisticsPreview(context),
              Divider(height: 32),
              _buildSettingsList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, userDataProvider, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  (userDataProvider.nickname ?? 'G')[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                userDataProvider.nickname ?? 'Guest',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPointCard(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, userDataProvider, _) {
        return ResponsiveContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PurchasePointPage(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '보유 포인트',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${userDataProvider.points} P',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PurchasePointPage(),
                            ),
                          );
                        },
                        child: const Text('충전하기'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsPreview(BuildContext context) {
    return ResponsiveContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '학습 통계',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Icon(
                        Icons.analytics_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '곧 새로운 통계 기능이 제공됩니다',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    List<Map<String, dynamic>> settings = [
      {
        'title': '포인트 사용내역',
        'icon': Icons.history,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PointTransactionHistoryPage(),
            ),
          );
        },
      },
      {
        'title': '전화번호 수정', // 새로 추가
        'icon': Icons.phone,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChangePhoneScreen(),
            ),
          );
        },
      },
      {
        'title': '문의하기',
        'icon': Icons.help,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InquiryPage(),
            ),
          );
        },
      },
      {'title': '회사 정보', 'icon': Icons.info},
      {'title': '개인정보처리방침', 'icon': Icons.security},
      {'title': '이용약관', 'icon': Icons.description},
      {'title': '버전 정보', 'icon': Icons.new_releases},
      {
        'title': '로그아웃',
        'icon': Icons.logout,
        'onTap': () => _handleLogout(context),
      },
    ];

    return ResponsiveContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('고객 지원',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ...settings.map((setting) => ListTile(
                leading: Icon(setting['icon']),
                title: Text(setting['title']),
                trailing: Icon(Icons.chevron_right),
                onTap: setting['onTap'],
              )),
        ],
      ),
    );
  }
}
