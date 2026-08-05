import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/theme.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthController authController = Get.find<AuthController>();
  bool _notifications = true;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications = prefs.getBool('notifications') ?? true;
      _darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _toggleNotif(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', val);
    setState(() => _notifications = val);
  }

  Future<void> _toggleDark(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', val);
    setState(() => _darkMode = val);
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Center(child: Text((user['name'] ?? 'U').toString().substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: AppTheme.fontSectionTitle, fontWeight: FontWeight.bold, color: AppTheme.primaryColor))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['name'] ?? '', style: const TextStyle(color: AppTheme.textPrimary, fontSize: AppTheme.fontCardTitle, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(user['email'] ?? '', style: const TextStyle(color: AppTheme.textMuted, fontSize: AppTheme.fontBody)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Preferences', style: TextStyle(color: AppTheme.textSubtle, fontSize: AppTheme.fontMeta, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          _buildToggle('Notifications', Icons.notifications_outlined, _notifications, _toggleNotif),
          _buildToggle('Dark Mode', Icons.dark_mode_outlined, _darkMode, _toggleDark),
          const SizedBox(height: 24),
          const Text('Account', style: TextStyle(color: AppTheme.textSubtle, fontSize: AppTheme.fontMeta, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          _buildNav('Change Password', Icons.lock_outline, () => _showChangePasswordDialog()),
          _buildNav('Privacy Policy', Icons.privacy_tip_outlined, () => Get.snackbar('Info', 'Privacy policy page coming soon')),
          _buildNav('Help & Support', Icons.help_outline, () => Get.snackbar('Info', 'Support page coming soon')),
          _buildNav('About', Icons.info_outline, () => _showAboutDialog()),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showSignOutDialog(),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderColor)),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSubtle, size: 22),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: AppTheme.fontBody))),
          Switch(value: value, onChanged: onChanged, activeColor: AppTheme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildNav(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderColor)),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSubtle, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: AppTheme.fontBody))),
            const Icon(Icons.chevron_right, color: AppTheme.textSubtle, size: 22),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    Get.defaultDialog(
      title: 'Change Password',
      titleStyle: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
      backgroundColor: AppTheme.surfaceColor,
      content: Container(
        width: Get.width * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: currentCtrl, obscureText: true, decoration: _inputDecoration('Current password')),
            const SizedBox(height: 12),
            TextField(controller: newCtrl, obscureText: true, decoration: _inputDecoration('New password')),
            const SizedBox(height: 12),
            TextField(controller: confirmCtrl, obscureText: true, decoration: _inputDecoration('Confirm new password')),
          ],
        ),
      ),
      textConfirm: 'Update',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        if (newCtrl.text != confirmCtrl.text) {
          Get.snackbar('Error', 'Passwords do not match');
          return;
        }
        Get.back();
        Get.snackbar('Success', 'Password updated successfully');
      },
    );
  }

  void _showAboutDialog() {
    Get.defaultDialog(
      title: 'PMCFMS',
      titleStyle: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
      middleText: 'Public Meeting & Community Forum Management System\nVersion 1.0.0',
      middleTextStyle: const TextStyle(color: AppTheme.textMuted, fontSize: AppTheme.fontBody),
      backgroundColor: AppTheme.surfaceColor,
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
    );
  }

  void _showSignOutDialog() {
    Get.defaultDialog(
      title: 'Sign Out',
      titleStyle: const TextStyle(color: AppTheme.textPrimary),
      middleText: 'Are you sure you want to sign out?',
      middleTextStyle: const TextStyle(color: AppTheme.textSubtle),
      backgroundColor: AppTheme.surfaceColor,
      textConfirm: 'Sign Out',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppTheme.errorColor,
      onConfirm: () async {
        await authController.logout();
        Get.offAll(() => const LoginScreen());
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.textSubtle),
      filled: true,
      fillColor: AppTheme.backgroundColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
