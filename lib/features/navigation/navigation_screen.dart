import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/features/faq/faq_screen.dart';
import 'package:harari_prosperity_app/features/home/home_screen.dart';
import 'package:harari_prosperity_app/features/navigation/profile_screen.dart';
import 'package:harari_prosperity_app/features/report/report_history_screen.dart';
import 'package:harari_prosperity_app/shared/constants.dart';
import 'package:harari_prosperity_app/shared/widgets/confirmation_dialog.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/services/auth_state_manager.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;
  final AuthStateManager _authManager = AuthStateManager();


  static final List<Widget> _screens = [
    const HomeScreen(),
    const ReportHistoryScreen(),
    const FaqScreen(),
    const ProfileScreen(),
  ];

  static const List<String> _titles = [
    'Home',
    'Report History',
    'FAQ And Help',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: _screens[_selectedIndex],
      drawer: Drawer(
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  selected: _selectedIndex == 0,
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(0);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Setting'),
                  selected: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.settings);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('FAQ And Help'),
                  selected: _selectedIndex == 2,
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(2);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  selected: _selectedIndex == 3,
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(3);
                  },
                ),
                const SizedBox(height: 80), // Space for logout button
              ],
            ),
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: Padding(
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
                  label: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        title: 'End Session',
                        message: 'Are you sure you want to log out?',
                        confirmText: 'Yes',
                        confirmColor: AppColors.primary,
                        onConfirm: () async {
                          Navigator.pop(context); // Close dialog
                          
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          
                          try {
                            await _authManager.signOut();
                            if (context.mounted) {
                              Navigator.pop(context); // Close loading dialog first
                              // Clear all navigation stack and go to choice screen
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRoutes.choice,
                                (route) => false,
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context); // Close loading dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Logout failed: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            activeIcon: Icon(Icons.help),
            label: 'FAQ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
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