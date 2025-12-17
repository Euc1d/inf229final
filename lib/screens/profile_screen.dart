import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    setState(() {
      _notificationsEnabled = value;
    });

    if (value) {
      bool hasPermission = await NotificationService().areNotificationsEnabled();
      await NotificationService().showInstantNotification(
        title: '🔔 Notifications Enabled',
        body: 'You will now receive recipe reminders!',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasPermission
                ? 'Notifications enabled! Check your notification bar'
                : 'Please enable notifications in system settings'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications disabled')),
        );
      }
    }
  }

  Future<void> _testNotification() async {
    await NotificationService().showRecipeReminder();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test notification sent!')),
      );
    }
  }

  Future<void> _openTelegram() async {
    final Uri telegramUrl = Uri.parse('https://t.me/Euc1d');
    if (await canLaunchUrl(telegramUrl)) {
      await launchUrl(telegramUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Telegram')),
        );
      }
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📞 Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Need help or have suggestions?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            const Text('Contact me on Telegram:'),
            const SizedBox(height: 10),
            InkWell(
              onTap: _openTelegram,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    Icon(Icons.telegram, color: Colors.blue),
                    const SizedBox(width: 10),
                    const Text('@Euc1d', style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text('I\'m here to help with:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _buildHelpItem('• Bug reports and issues'),
            _buildHelpItem('• Feature suggestions'),
            _buildHelpItem('• Recipe recommendations'),
            _buildHelpItem('• Any questions or feedback'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _openTelegram();
            },
            icon: const Icon(Icons.telegram, color: Colors.white),
            label: const Text('Open Telegram', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Text(text, style: TextStyle(color: Colors.grey[700])),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.orange,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(user.email, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 30),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 5)],
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.notifications, color: Colors.blue),
                    ),
                    title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(_notificationsEnabled ? 'Enabled' : 'Disabled'),
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                    activeColor: Colors.blue,
                  ),
                  if (_notificationsEnabled) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.send, color: Colors.orange),
                      ),
                      title: const Text('Test Notification', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Send a test notification'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _testNotification,
                    ),
                  ],
                  const Divider(height: 1),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return SwitchListTile(
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.dark_mode, color: Colors.purple),
                        ),
                        title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(themeProvider.isDarkMode ? 'Enabled' : 'Disabled'),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) => themeProvider.toggleTheme(),
                        activeColor: Colors.purple,
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileTile(
                    context: context,
                    icon: Icons.help,
                    title: 'Help & Support',
                    subtitle: 'Get help or contact developer',
                    color: Colors.green,
                    onTap: _showHelpDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Logout', style: TextStyle(fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Version 1.0.0', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}