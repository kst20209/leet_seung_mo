import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/problem_solving_page.dart' as problem_solving;
import 'screens/my_page.dart';
import 'screens/home_screen.dart';
import 'screens/problem_shop_page.dart';
import 'screens/my_problem_page.dart' as my_problem;
import 'screens/problem_set_list_page.dart';
import 'screens/problem_list_page.dart';
import 'models/models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
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
          elevation: 0,
          toolbarHeight: 50,
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
          secondary: const Color(0xFF74512D),
          surface: const Color(0xFFF8F4E1),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: const Color(0xFF543310),
        ),
      ),
      initialRoute: '/',
      routes: {
        // routes 수정
        '/': (context) => const MainScreen(),
        '/subject_list': (context) => const ProblemSetListPage(),
        '/problem_list': (context) =>
            const ProblemListPage(title: '', items: []),
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

// MainScreen
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: '상점',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: '문제',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        onTap: _onItemTapped,
      ),
    );
  }
}
