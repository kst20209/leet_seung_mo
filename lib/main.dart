// import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'screens/purchase_point_page.dart';
import 'utils/firebase_service.dart';
import 'package:http/http.dart' as http;

// providers
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/user_data_provider.dart';

// screens
import 'screens/problem_solving_page.dart' as problem_solving;
import 'screens/my_page.dart';
import 'screens/home_screen.dart';
import 'screens/problem_shop_page.dart';
import 'screens/my_problem_page.dart' as my_problem;
import 'screens/problem_set_list_page.dart';
import 'screens/problem_list_page.dart';
import 'screens/landing_screen.dart';

// models
import 'models/models.dart';

Future<bool> checkInternetConnection() async {
  try {
    // Google의 DNS 서버로 실제 연결 테스트
    final response = await http
        .get(
          Uri.parse('https://8.8.8.8'),
        )
        .timeout(const Duration(seconds: 5));

    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 실제 인터넷 연결 확인
  bool hasInternet = await checkInternetConnection();
  if (!hasInternet) {
    runApp(NoInternetApp());
    return;
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // FirebaseFunctions.instanceFor(region: 'us-central1');
  final firebaseService = FirebaseService();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProxyProvider<AppAuthProvider, UserDataProvider>(
          create: (_) => UserDataProvider(firebaseService),
          update: (_, auth, previous) {
            final provider = previous ?? UserDataProvider(firebaseService);
            if (auth.status == AuthStatus.authenticated && auth.user != null) {
              // 인증 상태일 때만 데이터 로드
              provider.loadUserData(auth.user!.uid);
            } else if (auth.status == AuthStatus.unauthenticated) {
              // 미인증 상태일 때만 데이터 초기화
              provider.clearData();
            }
            return provider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// 인터넷 연결이 없을 때 표시할 화면
class NoInternetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: const MaterialColor(0xFFAF8F6F, {
          50: Color(0xFFF8F4E1),
          100: Color(0xFFF1E9C3),
          200: Color(0xFFE9DDA5),
          300: Color(0xFFE1D187),
          400: Color(0xFFD9C569),
          500: Color(0xFFAF8F6F),
          600: Color(0xFF9A7B5B),
          700: Color(0xFF856747),
          800: Color(0xFF705333),
          900: Color(0xFF543310),
        }),
        scaffoldBackgroundColor: const Color(0xFFF8F4E1),
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                size: 64,
                color: Color(0xFFAF8F6F),
              ),
              SizedBox(height: 16),
              Text(
                '인터넷 연결 없음',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF543310),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: 300,
                alignment: Alignment.center,
                child: Text(
                  '앱 사용을 위해서는 인터넷 연결이 필요합니다.',
                  style: TextStyle(
                    color: Color(0xFF74512D),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '리승모: 리트 승리의 모든 것',
      theme: ThemeData(
        primarySwatch: const MaterialColor(0xFFAF8F6F, {
          50: Color(0xFFF8F4E1),
          100: Color(0xFFF1E9C3),
          200: Color(0xFFE9DDA5),
          300: Color(0xFFE1D187),
          400: Color(0xFFD9C569),
          500: Color(0xFFAF8F6F),
          600: Color(0xFF9A7B5B),
          700: Color(0xFF856747),
          800: Color(0xFF705333),
          900: Color(0xFF543310),
        }),
        scaffoldBackgroundColor: const Color(0xFFF8F4E1),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F4E1),
          foregroundColor: Color(0xFF543310),
          elevation: 0.1,
          shadowColor: Color.fromARGB(255, 20, 11, 0),
          toolbarHeight: 50,
          shape: Border(
            bottom: BorderSide(
              color: Colors.black12,
              width: 0.5,
            ),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF543310)),
          displayMedium: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF543310)),
          displaySmall: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF543310)),
          headlineMedium: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF543310)),
          titleLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF543310)),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF74512D)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF74512D)),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFFAF8F6F),
            textStyle: const TextStyle(fontSize: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFAF8F6F),
          primary: const Color(0xFFAF8F6F),
          secondary: const Color(0xFF543310),
          surface: const Color(0xFFF8F4E1),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: const Color(0xFF543310),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => _handleAuthState(context),
        '/main': (context) => const PopScope(
              canPop: false, // 뒤로가기 버튼 비활성화
              child: const MainScreen(),
            ),
        '/subject_list': (context) => const ProblemSetListPage(),
        '/problem_list': (context) => const ProblemListPage(title: ''),
        '/purchase_point': (context) => const PurchasePointPage(),
        '/problem_shop': (context) => const ProblemShopPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/problem_solving') {
          final args = settings.arguments as Problem;
          return MaterialPageRoute(
            builder: (context) {
              return problem_solving.ProblemSolvingPage(problem: args);
            },
          );
        }
        return null;
      },
    );
  }
}

Widget _handleAuthState(BuildContext context) {
  return Consumer<AppAuthProvider>(
    builder: (context, auth, _) {
      switch (auth.status) {
        case AuthStatus.uninitialized:
          return const Center(child: CircularProgressIndicator());
        case AuthStatus.authenticated:
          return const MainScreen();
        case AuthStatus.unauthenticated:
          return LandingScreen();
      }
    },
  );
}

// MainScreen
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _hasShownWelcome = false;
  int _selectedIndex = 0;
  Function? _removeListener;

  @override
  void initState() {
    super.initState();

    if (!_hasShownWelcome) {
      final userDataProvider = context.read<UserDataProvider>();

      // ScaffoldMessenger의 현재 SnackBar를 제거하고 새로운 SnackBar를 표시하는 함수
      void showWelcomeSnackBar() {
        if (!mounted) return;

        // 현재 표시 중인 SnackBar를 모두 제거
        ScaffoldMessenger.of(context).clearSnackBars();

        // 새로운 SnackBar 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${userDataProvider.nickname ?? 'Guest'} 님 환영합니다'),
            duration: const Duration(seconds: 1),
            // 새로운 SnackBar가 이전 SnackBar를 대체하지 않도록 설정
            behavior: SnackBarBehavior.fixed,
          ),
        );
      }

      void showWelcomeMessage() {
        if (userDataProvider.status == UserDataStatus.loaded &&
            !_hasShownWelcome &&
            mounted) {
          // 단일 프레임에서 한 번만 실행되도록 보장
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_hasShownWelcome) return; // 이미 표시했다면 중단
            _hasShownWelcome = true;
            showWelcomeSnackBar();
            _removeListener?.call();
          });
        }
      }

      _removeListener =
          () => userDataProvider.removeListener(showWelcomeMessage);
      userDataProvider.addListener(showWelcomeMessage);

      if (userDataProvider.status == UserDataStatus.loaded) {
        showWelcomeMessage();
      }
    }
  }

  @override
  void dispose() {
    // 위젯이 dispose될 때 리스너 제거
    _removeListener?.call();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AppAuthProvider>(context);
    if (authProvider.status == AuthStatus.authenticated) {
      _hasShownWelcome = false;
    }
  }

  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ProblemShopPage(),
    my_problem.MyProblemPage(),
    MyPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Container(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0.1,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 28),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.secondary,
          unselectedItemColor: Theme.of(context).colorScheme.primary,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
