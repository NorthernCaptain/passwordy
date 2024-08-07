import 'package:flutter/material.dart';
import 'package:passwordy/service/log.dart';
import 'package:passwordy/widgets/nav_item.dart';
import 'package:passwordy/widgets/new_item_chooser.dart';
import 'package:passwordy/widgets/search_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    NotificationsPage(),
    ProfilePage(),
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
              SearchWidget(onSearch: _handleSearch),
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

  void _handleSearch(String query) {
    lg?.i('Searching for: $query');
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Container(
        height: 80.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CircularNavItem(
              icon: Icons.home,
              label: 'Home',
              isSelected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            CircularNavItem(
              icon: Icons.search,
              label: 'Search',
              isSelected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            SizedBox(width: 60.0),
            CircularNavItem(
              icon: Icons.notifications,
              label: 'Notifications',
              isSelected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            CircularNavItem(
              icon: Icons.person,
              label: 'Profile',
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
      width: 65.0,
      height: 65.0,
      child: FloatingActionButton(
        onPressed: _showNewItemChooser,
        child: Icon(Icons.add, size: 32.0),
        elevation: 2.0,
        shape: CircleBorder(),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showNewItemChooser() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return NewItemChooser(
          onItemSelected: (String item) {
            // Handle the selected item
            print('Selected: $item');
            // Add your logic here to handle the selected item
          },
        );
      },
    );
  }
}

// Simple page widgets
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Page', style: TextStyle(fontSize: 24)),
    );
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Search Page', style: TextStyle(fontSize: 24)),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Notifications Page', style: TextStyle(fontSize: 24)),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile Page', style: TextStyle(fontSize: 24)),
    );
  }
}