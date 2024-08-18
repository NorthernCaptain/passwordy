import 'package:flutter/material.dart';
import 'package:passwordy/screens/create_password.dart';
import 'package:passwordy/screens/vault_list_screen.dart';
import 'package:passwordy/service/db/db_vault.dart';
import 'package:passwordy/service/utils.dart';
import 'package:passwordy/widgets/add_options_state.dart';
import 'package:passwordy/widgets/nav_item.dart';
import 'package:passwordy/screens/totp_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    VaultListScreen(),
    AuthenticatorScreen(vault: Vault.vault,),
    CreatePasswordScreen(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping outside of the search bar
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              Expanded(
                child: _pages[_selectedIndex],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomAppBar(),
      floatingActionButton: _buildMiddleButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CircularNavItem(
              icon: Icons.key,
              label: 'Vault',
              isSelected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            CircularNavItem(
              icon: Icons.generating_tokens_outlined,
              label: 'Tokens',
              isSelected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            const SizedBox(width: 60.0),
            CircularNavItem(
              icon: Icons.password,
              label: 'Passwords',
              isSelected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            CircularNavItem(
              icon: Icons.settings,
              label: 'Settings',
              isSelected: _selectedIndex == 3,
              onTap: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiddleButton() {
    return SizedBox(
      width: 60.0,
      height: 60.0,
      child: FloatingActionButton(
        onPressed: _showAddOptions,
        elevation: 2.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32.0),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddOptions() {
    _pages[_selectedIndex].asOrNull<AddOptionsWidget>()?.showAddOptions(context);
  }
}

// Simple page widgets
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Page', style: TextStyle(fontSize: 24)),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Notifications Page', style: TextStyle(fontSize: 24)),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile Page', style: TextStyle(fontSize: 24)),
    );
  }
}