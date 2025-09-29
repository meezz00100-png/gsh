import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/features/faq/faq_screen.dart';
import 'package:harari_prosperity_app/features/home/home_screen.dart';
import 'package:harari_prosperity_app/features/navigation/profile_screen.dart';
import 'package:harari_prosperity_app/features/report/report_history_screen.dart';
import 'package:harari_prosperity_app/shared/constants.dart';
import 'package:harari_prosperity_app/shared/widgets/confirmation_dialog.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/localization/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;
  static final List<Widget> _screens = [
    const HomeScreen(),
    const ReportHistoryScreen(),
    const FaqScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return context.translate('home');
      case 1:
        return context.translate('myReports');
      case 2:
        return context.translate('faq');
      case 3:
        return context.translate('profile');
      default:
        return context.translate('appTitle');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: _screens[_selectedIndex],
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      'Menu',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: Text(context.translate('home')),
                    selected: _selectedIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: Text(context.translate('settings')),
                    selected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.settings);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: Text(context.translate('helpAndSupport')),
                    selected: _selectedIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(2);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(context.translate('profile')),
                    selected: _selectedIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(3);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 24, right: 16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout),
                label: Text(
                  context.translate('logout'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => ConfirmationDialog(
                      title: context.translate('logout'),
                      message: context.translate('logoutConfirmation'),
                      confirmText: context.translate('yes'),
                      cancelText: context.translate('no'),
                      confirmColor: Colors.red,
                      onConfirm: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  );

                  if (confirmed != true) return;
                  
                  try {
                    // Sign out from Supabase first
                    await Supabase.instance.client.auth.signOut();
                  } catch (e) {
                    debugPrint('Error during sign out: $e');
                  } finally {
                    // Always navigate to choice screen in finally block
                    if (mounted) {
                      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                        AppRoutes.choice,
                        (route) => false,
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: context.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: context.translate('myReports'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            activeIcon: Icon(Icons.help),
            label: context.translate('faq'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: context.translate('profile'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
