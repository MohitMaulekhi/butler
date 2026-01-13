import 'package:butler_flutter/screens/calendar_page.dart';
import 'package:butler_flutter/screens/chat_page.dart';
import 'package:butler_flutter/screens/news_page.dart';
import 'package:butler_flutter/screens/profile_page.dart';
import 'package:butler_flutter/screens/tasks_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  // Keys to force refresh when tapping the tab
  final _tasksKey = GlobalKey<TasksPageState>();
  final _calendarKey = GlobalKey<CalendarPageState>();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const ChatPage(),
      TasksPage(key: _tasksKey),
      CalendarPage(key: _calendarKey),
      const NewsPage(),
      const ProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Refresh data when switching to these tabs
    if (index == 1 && _tasksKey.currentState != null) {
        _tasksKey.currentState?.loadTasks();
    } else if (index == 2 && _calendarKey.currentState != null) {
        _calendarKey.currentState?.loadEvents();
    }
  }
  
  String _getTitle(int index) {
      switch (index) {
          case 0: return 'Butler Chat';
          case 1: return 'Tasks';
          case 2: return 'Calendar';
          case 3: return 'News';
          case 4: return 'Profile';
          default: return 'Butler';
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_currentIndex)),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
           NavigationDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat), label: 'Chat'),
           NavigationDestination(icon: Icon(Icons.check_circle_outline), selectedIcon: Icon(Icons.check_circle), label: 'Tasks'),
           NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: 'Calendar'),
           NavigationDestination(icon: Icon(Icons.newspaper_outlined), selectedIcon: Icon(Icons.newspaper), label: 'News'),
           NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
