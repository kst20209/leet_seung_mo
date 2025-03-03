import 'package:flutter/material.dart';
import 'package:leet_seung_mo/screens/login_screen.dart';
import 'package:leet_seung_mo/screens/signup/signup_screen.dart';
import 'package:leet_seung_mo/utils/responsive_container.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import './mypage/change_phone_screen.dart';
import 'mypage/add_phone_screen.dart';
import 'mypage/inquiry_page.dart';
import 'mypage/point_transaction_history_page.dart';
import './mypage/delete_account_verification_screen.dart';

import '../providers/user_data_provider.dart';
import '../utils/url_service.dart';
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

  // onTap에 들어갈 함수
  void _showDeleteAccountDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeleteAccountVerificationScreen(
          onVerificationSuccess: () {
            _confirmDeleteAccount(context);
          },
        ),
      ),
    );
  }

// 삭제 확인 대화상자
  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('계정 삭제'),
          content: Text(
            '정말로 계정을 삭제하시겠습니까?\n\n'
            '계정을 삭제하면 다음과 같은 데이터가 영구적으로 삭제됩니다:\n'
            '- 개인 정보 및 설정\n'
            '- 구매한 포인트\n\n'
            '이 작업은 되돌릴 수 없습니다.',
          ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                '계정 삭제',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _executeAccountDeletion(context);
              },
            ),
          ],
        );
      },
    );
  }

// 계정 삭제 실행
  Future<void> _executeAccountDeletion(BuildContext context) async {
    // 컨텍스트 참조를 미리 저장
    final navigatorContext = Navigator.of(context);

    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('계정을 삭제 중입니다...'),
              ],
            ),
          );
        },
      );

      // AppAuthProvider를 통해 deleteAccount 호출
      final appAuthProvider = context.read<AppAuthProvider>();
      await appAuthProvider.deleteAccount();

      // 저장해둔 컨텍스트 사용
      navigatorContext.pop();

      // 새로운 컨텍스트에서 다이얼로그 표시 시도
      navigatorContext.pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      // 로딩 다이얼로그 닫기 시도
      try {
        navigatorContext.pop();
      } catch (navError) {
        print('Navigator 오류(오류 경로): $navError');
      }

      // 에러 메시지는 SnackBar로 표시 (다이얼로그 대신)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('계정 삭제 중 오류가 발생했습니다. 고객센터로 문의해주십시오.')),
      );
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
        final authProvider = context.read<AppAuthProvider>();
        final isGuest = authProvider.isGuest;
        return ResponsiveContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: InkWell(
                onTap: isGuest
                    ? null
                    : () {
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
                        onPressed: isGuest
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PurchasePointPage(),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isGuest
                              ? Colors.grey
                              : Theme.of(context).primaryColor,
                        ),
                        child: Text(isGuest ? '로그인 필요' : '충전하기'),
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
    final authProvider = context.read<AppAuthProvider>();
    final isGuest = authProvider.isGuest;
    final user = context.read<AppAuthProvider>().user;
    final hasPhoneNumber =
        !isGuest && user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty;

    List<Map<String, dynamic>> settings = [];

    // 게스트 모드일 때와 로그인한 사용자일 때 서로 다른 설정 항목 표시
    if (isGuest) {
      // 게스트 모드인 경우의 설정 항목
      settings = [
        {
          'title': '로그인하기',
          'icon': Icons.login,
          'onTap': () {
            authProvider.exitGuestMode();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        },
        {
          'title': '회원가입하기',
          'icon': Icons.person_add,
          'onTap': () {
            authProvider.exitGuestMode();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignUpScreen()),
            );
          },
        },
        {
          'title': '개인정보처리방침',
          'icon': Icons.security,
          'onTap': () {
            UrlService.launchURL(UrlService.privacyPolicyUrl);
          },
        },
        {
          'title': '이용약관',
          'icon': Icons.description,
          'onTap': () {
            UrlService.launchURL(UrlService.policyOfServiceUrl);
          },
        },
        {
          'title': '버전 정보',
          'icon': Icons.new_releases,
          'onTap': null,
        },
      ];
    } else {
      // 로그인한 사용자인 경우의 설정 항목
      settings = [
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
          'title': hasPhoneNumber ? '전화번호 수정' : '휴대전화 추가',
          'icon': Icons.phone,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => hasPhoneNumber
                    ? const ChangePhoneScreen()
                    : const AddPhoneScreen(),
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
        {
          'title': '개인정보처리방침',
          'icon': Icons.security,
          'onTap': () {
            UrlService.launchURL(UrlService.privacyPolicyUrl);
          },
        },
        {
          'title': '이용약관',
          'icon': Icons.description,
          'onTap': () {
            UrlService.launchURL(UrlService.policyOfServiceUrl);
          },
        },
        {
          'title': '버전 정보',
          'icon': Icons.new_releases,
          'onTap': null,
        },
        {
          'title': '로그아웃',
          'icon': Icons.logout,
          'onTap': () => _handleLogout(context),
        },
        {
          'title': '계정 탈퇴',
          'icon': Icons.delete_forever,
          'onTap': () => _showDeleteAccountDialog(context),
        },
      ];
    }

    return ResponsiveContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isGuest ? '계정' : '고객 지원',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ...settings.map((setting) => ListTile(
                leading: Icon(setting['icon']),
                title: Text(setting['title']),
                trailing:
                    setting['onTap'] != null ? Icon(Icons.chevron_right) : null,
                onTap: setting['onTap'],
              )),
        ],
      ),
    );
  }
}
