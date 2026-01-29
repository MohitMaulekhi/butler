import 'package:butler_flutter/screens/calendar_page.dart';
import 'package:butler_flutter/screens/chat_page.dart';
import 'package:butler_flutter/screens/news_page.dart';
import 'package:butler_flutter/screens/profile_page.dart';
import 'package:butler_flutter/screens/tasks_page.dart';
import 'package:butler_client/butler_client.dart';
import 'package:butler_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final _tasksKey = GlobalKey<TasksPageState>();
  final _calendarKey = GlobalKey<CalendarPageState>();
  final _chatKey = GlobalKey<ChatPageState>();

  late List<Widget> _pages;
  List<ChatSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _pages = [
      ChatPage(
        key: _chatKey,
        sessions: _sessions,
        onSessionsUpdated: _loadSessions,
      ),
      TasksPage(key: _tasksKey),
      CalendarPage(key: _calendarKey),
      const NewsPage(),
      const ProfilePage(),
    ];
    _loadSessions();
  }

  void _onItemTapped(int index) {
    if (index == 0 && _currentIndex == 0) {
      // If already on chat, reset it (New Chat behavior from Sidebar button)
      _chatKey.currentState?.reset();
    }

    setState(() {
      _currentIndex = index;
    });

    if (index == 1 && _tasksKey.currentState != null) {
      _tasksKey.currentState?.loadTasks();
    } else if (index == 2 && _calendarKey.currentState != null) {
      _calendarKey.currentState?.loadEvents();
    }
  }

  Future<void> _loadSessions() async {
    final sessionManager = client.authSessionManager;
    if (sessionManager.authInfo == null) return;

    try {
      final sessions = await client.chat.getSessions();
      if (mounted) {
        setState(() {
          _sessions = sessions;
          // Re-build pages to update ChatPage params if needed,
          // but since we pass _sessions by reference (it's a list),
          // we might need to recreate the page or depend on ChatPage
          // using didUpdateWidget (which we implemented).
          // However, we passed the list instance. If we replaced the list instance
          // we need to update the widget in _pages or ensure ChatPage.build reads new widget.sessions.
          // Since _pages is initialized once, updating _sessions here WON'T update
          // the ChatPage instance inside _pages array automatically unless we update the array.
          _pages[0] = ChatPage(
            key: _chatKey,
            sessions: _sessions,
            onSessionsUpdated: _loadSessions,
          );
        });
      }
    } catch (e) {
      debugPrint('Failed to load sessions: $e');
    }
  }

  void _onSessionTapped(ChatSession session) {
    setState(() {
      _currentIndex = 0;
    });
    // Add small delay to allow widget to build if switching tabs
    Future.microtask(() {
      _chatKey.currentState?.loadSession(session.id!);
    });
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Butler Chat';
      case 1:
        return 'Tasks';
      case 2:
        return 'Calendar';
      case 3:
        return 'News';
      case 4:
        return 'Profile';
      default:
        return 'Butler';
    }
  }

  // Check if screen is wide enough for desktop layout
  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 900;
  }

  Widget _sidebarItem(
    int index,
    IconData icon,
    IconData selectedIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final isTablet = _isTablet(context);
    final theme = Theme.of(context);

    // Desktop layout with NavigationRail
    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Custom Side Sidebar
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                border: Border(
                  right: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.2,
                    ),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // New Chat Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Material(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      elevation: 1,
                      child: InkWell(
                        onTap: () => _onItemTapped(0),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: theme.colorScheme.onPrimary,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'New Chat',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Nav Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        _sidebarItem(
                          0,
                          Icons.chat_bubble_outline,
                          Icons.chat_bubble,
                          'Chat',
                        ),
                        _sidebarItem(
                          1,
                          Icons.check_circle_outline,
                          Icons.check_circle,
                          'Tasks',
                        ),
                        _sidebarItem(
                          2,
                          Icons.calendar_today_outlined,
                          Icons.calendar_today,
                          'Calendar',
                        ),
                        _sidebarItem(
                          3,
                          Icons.newspaper_outlined,
                          Icons.newspaper,
                          'News',
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            'PREFERENCES',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                              fontSize: 11,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _sidebarItem(
                          4,
                          Icons.settings_outlined,
                          Icons.settings,
                          'Settings',
                        ),
                        const SizedBox(height: 32),
                        // HISTORY SECTION
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            'HISTORY',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                              fontSize: 11,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        ..._sessions.map((session) {
                          final title = session.title;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            child: InkWell(
                              onTap: () => _onSessionTapped(session),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  // Branding / Footer
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.03,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BUTLER AI',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.9,
                                ),
                                fontSize: 13,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Premium Assistant',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            Container(width: 1, color: Colors.white10),
            // Main content area
            Expanded(
              child: Column(
                children: [
                  // App bar for non-chat pages
                  if (_currentIndex != 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        border: Border(
                          bottom: BorderSide(
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _getTitle(_currentIndex),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Content with max width constraint
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: IndexedStack(
                          index: _currentIndex,
                          children: _pages,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Tablet layout - bottom nav but with constrained width
    if (isTablet) {
      return Scaffold(
        appBar: _currentIndex == 0
            ? null
            : AppBar(
                title: Text(_getTitle(_currentIndex)),
                centerTitle: true,
              ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.chat_outlined),
              selectedIcon: Icon(Icons.chat),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.check_circle_outline),
              selectedIcon: Icon(Icons.check_circle),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.newspaper_outlined),
              selectedIcon: Icon(Icons.newspaper),
              label: 'News',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      );
    }

    // Mobile layout - original
    return Scaffold(
      appBar: _currentIndex == 0
          ? null
          : AppBar(
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
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper),
            label: 'News',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
