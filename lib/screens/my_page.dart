import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dart:convert';

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
    userData = _loadMockData();
  }

  Map<String, dynamic> _loadMockData() {
    // 가상의 사용자 데이터
    String jsonString = '''
    {
      "nickname": "테스트 사용자",
      "uid": "user123",
      "points": 1000,
      "totalSolvedProblems": 150,
      "weeklyStudyTime": 10,
      "monthlyStudyTime": 40,
      "studyDays": [1, 3, 5, 7, 10, 12, 15]
    }
    ''';
    return json.decode(jsonString);
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await context.read<AppAuthProvider>().signOut();
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
              _buildUserInfo(),
              Divider(height: 32),
              _buildLearningStats(),
              _buildLearningCalendar(),
              Divider(height: 32),
              _buildSettingsList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Consumer2<AppAuthProvider, UserDataProvider>(
      builder: (context, authProvider, userDataProvider, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${userDataProvider.nickname ?? 'Guest'}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _handleLogout(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('로그아웃'),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${userDataProvider.points} P',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PurchasePointPage(),
                      ),
                    );
                  },
                  child: Text('충전하기'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLearningStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('학습 통계',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('총 해결한 문제: ${userData['totalSolvedProblems']}'),
        Text('이번 주 학습 시간: ${userData['weeklyStudyTime']} 시간'),
        Text('이번 달 학습 시간: ${userData['monthlyStudyTime']} 시간'),
      ],
    );
  }

  Widget _buildLearningCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('학습 캘린더',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          height: 200,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: 30, // Simplified to show 30 days
            itemBuilder: (context, index) {
              bool hasStudied =
                  userData['studyDays']?.contains(index + 1) ?? false;
              return Container(
                margin: EdgeInsets.all(2),
                color: hasStudied ? Colors.blue : Colors.grey[300],
                child: Center(child: Text('${index + 1}')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    List<Map<String, dynamic>> settings = [
      {'title': '나의 구입 내역', 'icon': Icons.history},
      {'title': '문의하기', 'icon': Icons.help},
      {'title': '알림 설정', 'icon': Icons.notifications},
      {'title': '회사 정보', 'icon': Icons.info},
      {'title': '개인정보처리방침', 'icon': Icons.security},
      {'title': '이용약관', 'icon': Icons.description},
      {'title': '버전 정보', 'icon': Icons.new_releases},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('설정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ...settings.map((setting) => ListTile(
              leading: Icon(setting['icon']),
              title: Text(setting['title']),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            )),
      ],
    );
  }
}
