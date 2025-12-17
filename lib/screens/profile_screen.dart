import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'edit_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _avatarPath = prefs.getString('avatar_${authProvider.user?.id}');
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
            _avatarPath != null && File(_avatarPath!).existsSync()
                ? ClipOval(
              child: Image.file(
                File(_avatarPath!),
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            )
                : CircleAvatar(
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
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                _loadPreferences();
              },
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
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
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.cloud_download, color: Colors.red),
                    ),
                    title: const Text('Load Default Recipes', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Load 10 Arabic recipes (admin only)'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _loadDefaultRecipes,
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
  Future<void> _loadDefaultRecipes() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // ПРОВЕРЯЕМ - уже загружены или нет?
      final existing = await firestore
          .collection('recipes')
          .where('userId', isEqualTo: 'default')
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Default recipes already loaded!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Показываем подтверждение
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Load Default Recipes'),
          content: const Text('This will load 10 Arabic recipes. Continue?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Load')),
          ],
        ),
      );

      if (confirm != true) return;

      // Показываем прогресс
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Loading recipes...'),
                ],
              ),
            ),
          ),
        ),
      );

      final recipes = [
        {
          'title': 'Hummus',
          'description': 'Creamy Middle Eastern chickpea dip',
          'category': 'Snack',
          'cookingTime': 15,
          'servings': 4,
          'ingredients': ['2 cups chickpeas', '1/4 cup tahini', '2 cloves garlic', '3 tbsp lemon juice', '2 tbsp olive oil', 'Salt', 'Paprika'],
          'steps': ['Blend chickpeas, tahini, garlic, lemon', 'Add water until smooth', 'Season with salt', 'Serve with olive oil and paprika'],
          'imageUrl': 'https://images.unsplash.com/photo-1637949385162-e416fb15b2ce?w=800',
          'userId': 'default',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        },
        {
          'title': 'Falafel',
          'description': 'Crispy chickpea balls',
          'category': 'Lunch',
          'cookingTime': 30,
          'servings': 4,
          'ingredients': ['2 cups chickpeas', '1 onion', '4 cloves garlic', '1 cup parsley', '1 cup cilantro', 'Spices', 'Oil'],
          'steps': ['Blend chickpeas with herbs', 'Form into balls', 'Deep fry until golden', 'Serve with tahini'],
          'imageUrl': 'https://plus.unsplash.com/premium_photo-1663853051660-91bd9b822799?w=800',
          'userId': 'default',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        },
        {
          'title': 'Chicken Shawarma',
          'description': 'Marinated chicken with spices',
          'category': 'Dinner',
          'cookingTime': 45,
          'servings': 4,
          'ingredients': ['1 kg chicken', '4 cloves garlic', '2 tsp cumin', '2 tsp paprika', 'Lemon juice', 'Olive oil', 'Pita bread'],
          'steps': ['Mix spices with lemon and oil', 'Marinate chicken 2 hours', 'Grill until cooked', 'Serve in pita'],
          'imageUrl': 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=800',
          'userId': 'default',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        },
        {
          'title': 'Tabbouleh',
          'description': 'Fresh parsley salad',
          'category': 'Lunch',
          'cookingTime': 20,
          'servings': 4,
          'ingredients': ['2 cups parsley', '1/2 cup bulgur', '3 tomatoes', '1 cucumber', 'Green onions', 'Lemon juice', 'Olive oil'],
          'steps': ['Soak bulgur 15 minutes', 'Mix all vegetables', 'Add bulgur', 'Dress with lemon and oil'],
          'imageUrl': 'https://images.unsplash.com/photo-1529059997568-3d847b1154f0?w=800',
          'userId': 'default',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        },
        {
          'title': 'Fattoush',
          'description': 'Bread salad with sumac',
          'category': 'Lunch',
          'cookingTime': 15,
          'servings': 4,
          'ingredients': ['2 pita breads', '4 cups lettuce', '2 tomatoes', '1 cucumber', 'Radishes', 'Lemon juice', 'Sumac'],
          'steps': ['Toast pita and break', 'Mix vegetables', 'Add dressing', 'Add pita before serving'],
          'imageUrl': 'https://images.unsplash.com/photo-1546069901-eacef0df6022?w=800',
          'userId': 'default',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        },
        {
          'title': 'Mansaf',
          'description': 'Jordanian lamb with yogurt',
          'category': 'Dinner',
          'cookingTime': 90,
          'servings': 6,
          'ingredients': ['1 kg lamb', '3 cups jameed', '3 cups rice', 'Butter', 'Pine nuts', 'Almonds', 'Spices'],
          'steps': ['Boil lamb until tender', 'Prepare jameed sauce', 'Cook rice', 'Toast nuts', 'Layer and serve'],
          'imageUrl': 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=800',
          'userId': 'default',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        },
        {
          'title': 'Mujadara',
          'description': 'Lentils and rice',
          'category': 'Dinner',
          'cookingTime': 45,
          'servings': 4,
          'ingredients': ['1 cup lentils', '1 cup rice', '3 onions', 'Olive oil', 'Cumin', 'Salt'],
          'steps': ['Cook lentils', 'Caramelize onions', 'Add rice to lentils', 'Top with onions'],
          'imageUrl': 'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=800',
          'userId': 'default',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        },
        {
          'title': 'Kunafa',
          'description': 'Sweet cheese pastry',
          'category': 'Dessert',
          'cookingTime': 40,
          'servings': 8,
          'ingredients': ['500g kunafa dough', '500g cheese', 'Butter', 'Sugar', 'Rose water', 'Pistachios'],
          'steps': ['Mix dough with butter', 'Layer with cheese', 'Bake until golden', 'Pour syrup', 'Garnish'],
          'imageUrl': 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=800',
          'userId': 'default',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        },
        {
          'title': 'Baklava',
          'description': 'Phyllo pastry with nuts',
          'category': 'Dessert',
          'cookingTime': 60,
          'servings': 12,
          'ingredients': ['Phyllo dough', '2 cups walnuts', '1 cup pistachios', 'Butter', 'Sugar', 'Honey'],
          'steps': ['Layer phyllo with butter', 'Add nuts between layers', 'Cut and bake', 'Pour syrup'],
          'imageUrl': 'https://images.unsplash.com/photo-1519676867240-f03562e64548?w=800',
          'userId': 'default',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        },
        {
          'title': 'Arabic Coffee',
          'description': 'Traditional spiced coffee',
          'category': 'Snack',
          'cookingTime': 15,
          'servings': 4,
          'ingredients': ['3 tbsp coffee beans', '3 cups water', 'Cardamom', 'Saffron', 'Sugar'],
          'steps': ['Boil water', 'Add coffee and cardamom', 'Simmer 5 minutes', 'Let settle', 'Serve with dates'],
          'imageUrl': 'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=800',
          'userId': 'default',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        },
      ];

      for (var recipe in recipes) {
        await firestore.collection('recipes').add(recipe);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 10 recipes loaded!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}