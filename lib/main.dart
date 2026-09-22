import 'package:flutter/material.dart';
import 'package:library0407/screens/admin_dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_controller.dart';
import 'screens/ebook_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/new_arrivals_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/e_resources_screen.dart';
import 'screens/journal_search_screen.dart';
import 'screens/suggestions_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/qbsearch_screen.dart';
import 'screens/newsclipping_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'models/user.dart';
import 'screens/chatbot_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/config.env");

  runApp(const LibraryApp());

}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ThemeController.instance.load(),
      builder: (context, snapshot) {
        return AnimatedBuilder(
          animation: ThemeController.instance,
          builder: (context, _) {
            final isDark = ThemeController.instance.isDark;
            return MaterialApp(
              title: 'MCET  Library',
              debugShowCheckedModeBanner: false,
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              theme: ThemeData(
                primarySwatch: Colors.indigo,
                brightness: Brightness.light,
              ),
              darkTheme: ThemeData(
                colorScheme: const ColorScheme.dark(primary: Colors.indigo),
                brightness: Brightness.dark,
              ),
              home: const LoginScreen(),
              initialRoute: '/login',
              routes: {
                '/login': (context) => const LoginScreen(),
                '/register': (context) => const RegisterScreen(),
                '/home': (context) => const MainPage(),
                '/admin': (context) => const AdminDashboardScreen(),
              },
            );
          },
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  bool _chatOpen = false; // Used to toggle chatbot visibility

  final User currentUser = User(
    id: "222",
    name: "Student One",
    email: "student.one@mcet.in",
    profileImage: "https://i.pravatar.cc/150?img=3",
  );

  String _displayName = 'Student One';
  String _displayEmail = 'student.one@mcet.in';

  final List<Widget> _screens = const [
    DashboardScreen(),
    NewArrivalsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadLoggedInUser();
  }

  Future<void> _loadLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    final email = prefs.getString('email');
    if (!mounted) return;
    setState(() {
      if (name != null && name.isNotEmpty) _displayName = name;
      if (email != null && email.isNotEmpty) _displayEmail = email;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateTo(BuildContext context, Widget screen, String title) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: screen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MCET College Library"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(currentUser.profileImage),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _displayEmail,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.indigo),
              title: const Text("E-Resources"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EResourcesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.indigo),
              title: const Text("Journals"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JournalSearchScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback, color: Colors.indigo),
              title: const Text("Suggestions"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SuggestionsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.recommend, color: Colors.indigo),
              title: const Text("Recommendations"),
              onTap: () => _navigateTo(
                  context, const RecommendationScreen(), "Recommendations"),
            ),
            ListTile(
              leading: const Icon(Icons.insights, color: Colors.indigo),
              title: const Text("Insights"),
              onTap: () =>
                  _navigateTo(context, const InsightsScreen(), "Insights"),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.question_answer, color: Colors.indigo),
              title: const Text("QB Search"),
              onTap: () =>
                  _navigateTo(context, const QuestionBankScreen(), "QB Search"),
            ),
            ListTile(
              leading: const Icon(Icons.newspaper, color: Colors.indigo),
              title: const Text("News Clipping"),
              onTap: () => _navigateTo(
                  context, const NewsClippingScreen(), "News Clipping"),
            ),
            ListTile(
              leading: const Icon(Icons.book_online, color: Colors.indigo),
              title: const Text("E-Book"),
              onTap: () =>
                  _navigateTo(context, const EBookScreen(), "E-Book"),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      onDrawerChanged: (isOpen) {
        if (isOpen) {
          _loadLoggedInUser();
        }
      },
      body: Stack(
        children: [
          _screens[_selectedIndex],
          if (_chatOpen)
            ChatbotPopup(
              onClose: () {
                setState(() {
                  _chatOpen = false;
                });
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: Icon(_chatOpen ? Icons.close : Icons.chat),
        onPressed: () {
          setState(() {
            _chatOpen = !_chatOpen;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.new_releases), label: 'New'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
