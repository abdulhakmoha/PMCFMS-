import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/theme.dart';
import '../controllers/auth_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/language_controller.dart';
import '../views/dashboard/dashboard_screen.dart';
import '../views/meetings/meetings_screen.dart';
import '../views/forums/forums_screen.dart';
import '../views/announcements/announcements_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/polls/polls_screen.dart';
import '../views/documents/documents_screen.dart';
import '../views/projects/projects_screen.dart';
import '../views/issues/issues_screen.dart';
import '../views/users/users_screen.dart';
import '../views/settings/settings_screen.dart';
import '../views/auth/login_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final NotificationController notifCtrl = Get.put(NotificationController());
  final LanguageController langCtrl = Get.find<LanguageController>();
  final AuthController authCtrl = Get.find<AuthController>();

  bool get _isAdminOrMod => authCtrl.user['role'] == 'admin' || authCtrl.user['role'] == 'moderator' || authCtrl.user['role'] == 'secretary';

  final List<Widget> _screens = [
    DashboardScreen(),
    MeetingsScreen(),
    ForumsScreen(),
    AnnouncementsScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = ['dashboard', 'meetings', 'forums', 'announcements', 'profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Obx(() => Text(langCtrl.t(_titles[_currentIndex]))),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 22),
            onPressed: () => _showGlobalSearch(),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22),
                onPressed: () => _showNotifications(),
              ),
              Obx(() => notifCtrl.hasUnread.value
                  ? Positioned(
                      right: 8, top: 8,
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      ),
                    )
                  : const SizedBox()),
            ],
          ),
          Obx(() => IconButton(
            icon: Text(langCtrl.currentLang.value.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            onPressed: () => langCtrl.toggleLanguage(),
          )),
        ],
      ),
      drawer: _buildDrawer(),
      body: Obx(() => _screens[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppTheme.backgroundColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSubtle,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: langCtrl.t('home')),
          BottomNavigationBarItem(icon: Icon(Icons.event_outlined), activeIcon: Icon(Icons.event), label: langCtrl.t('meetings')),
          BottomNavigationBarItem(icon: Icon(Icons.forum_outlined), activeIcon: Icon(Icons.forum), label: langCtrl.t('forums')),
          BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), activeIcon: Icon(Icons.campaign), label: langCtrl.t('updates')),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: langCtrl.t('profile')),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final user = authCtrl.user;
    final name = user['name'] ?? 'User';
    final email = user['email'] ?? '';
    final role = (user['role'] ?? 'citizen').toString();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Drawer(
      backgroundColor: AppTheme.surfaceColor,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 20, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF065F46), Color(0xFF10B981)]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: user['profileImage'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network('http://10.0.2.2:5001${user['profileImage']}', width: 60, height: 60, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Text(initial, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
                        )
                      : Text(initial, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(email, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: Text(role, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(Icons.dashboard_outlined, 'dashboard', '/dashboard', 0),
                _drawerItem(Icons.event_outlined, 'meetings', '/meetings', 1),
                _drawerItem(Icons.forum_outlined, 'forums', '/forums', 2),
                _drawerItem(Icons.how_to_vote_outlined, 'polls', '/polls', null, screen: const PollsScreen()),
                _drawerItem(Icons.campaign_outlined, 'announcements', '/announcements', 3),
                _drawerItem(Icons.folder_outlined, 'documents', '/documents', null, screen: const DocumentsScreen()),
                _drawerItem(Icons.work_outline, 'projects', '/projects', null, screen: const ProjectsScreen()),
                _drawerItem(Icons.report_problem_outlined, 'issues', '/issues', null, screen: const IssuesScreen()),
                if (_isAdminOrMod)
                  _drawerItem(Icons.people_outline, 'users', '/users', null, screen: const UsersScreen()),
                _drawerItem(Icons.settings_outlined, 'settings', '/settings', null, screen: const SettingsScreen()),
                const Divider(color: AppTheme.borderColor),
                _drawerItem(Icons.person_outline, 'profile', '/profile', 4),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.borderColor))),
            child: InkWell(
              onTap: () async {
                await authCtrl.logout();
                Get.offAll(() => const LoginScreen());
              },
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red.shade400, size: 20),
                  const SizedBox(width: 12),
                  Obx(() => Text(langCtrl.t('logout'), style: TextStyle(color: Colors.red.shade400, fontSize: 14, fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String labelKey, String route, int? tabIndex, {Widget? screen}) {
    return Obx(() {
      final label = langCtrl.t(labelKey);
      final isActive = tabIndex != null && _currentIndex == tabIndex;
      return Container(
        decoration: isActive
            ? const BoxDecoration(
                border: Border(left: BorderSide(color: AppTheme.primaryColor, width: 3)),
              )
            : null,
        child: ListTile(
          leading: Icon(icon, color: isActive ? AppTheme.primaryColor : AppTheme.textSubtle, size: 22),
          title: Text(label, style: TextStyle(color: isActive ? AppTheme.textPrimary : AppTheme.textMuted, fontSize: 14, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
          onTap: () {
            Navigator.pop(context);
            if (tabIndex != null) {
              setState(() => _currentIndex = tabIndex);
            } else if (screen != null) {
              Get.to(() => screen);
            }
          },
        ),
      );
    });
  }

  void _showGlobalSearch() {
    final searchCtrl = TextEditingController();
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search meetings, forums, users...',
                  hintStyle: const TextStyle(color: AppTheme.textSubtle),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSubtle),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(color: AppTheme.textPrimary),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const Divider(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 48, color: AppTheme.textSubtle),
                    const SizedBox(height: 12),
                    Text('Type to search across all sections', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.75,
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.notifications_outlined, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Text('Notifications', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => notifCtrl.markAllRead(),
                    child: Text('Mark all read', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Obx(() {
                if (notifCtrl.notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 48, color: AppTheme.textSubtle),
                        const SizedBox(height: 12),
                        Text('No notifications', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: notifCtrl.notifications.length,
                  itemBuilder: (_, i) {
                    final n = notifCtrl.notifications[i];
                    final isRead = n['read'] == true || n['isRead'] == true;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isRead ? Colors.transparent : AppTheme.primaryColor.withOpacity(0.05),
                        border: const Border(bottom: BorderSide(color: AppTheme.borderColor, width: 0.5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 8, height: 8, margin: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(color: isRead ? Colors.transparent : AppTheme.primaryColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n['title'] ?? '', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                                if (n['message'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text(n['message'], style: TextStyle(color: AppTheme.textMuted, fontSize: 12), maxLines: 2),
                                ],
                                if (n['createdAt'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text(n['createdAt'].toString().substring(0, 10), style: TextStyle(color: AppTheme.textSubtle, fontSize: 10)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
