import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import 'menu_screen.dart';
import 'contact_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userName = auth.user?.displayName ?? 'Guest';

    return Scaffold(
      backgroundColor: Colors.white,  // White background like login/signup
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text(
          'Restaurant Menu',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.redAccent,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Image.network(
                      "https://hypnopompblog.files.wordpress.com/2020/12/chinese.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'WELCOME',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 5,
                          shadows: [Shadow(color: Colors.black, blurRadius: 3)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.menu),
                    title: const Text('Menu'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MenuScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.contact_page),
                    title: const Text('Contact / About'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ContactScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  _showLogoutDialog(context, isFromDrawer: true);
                },
              ),
            )
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/homeimage.jpg', // Your local asset image
            fit: BoxFit.cover,
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.redAccent.withOpacity(0.7), // Use red accent overlay with opacity
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome to Our Restaurant, $userName!',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Description: Experience authentic flavors in a warm, inviting atmosphere. '
                        'Our chefs craft each dish with fresh ingredients and a passion for quality, '
                        'bringing you the best of traditional Chinese cuisine.',
                    style: TextStyle(color: Colors.white),
                  ),
                  const Text(
                    'Address: 123 Food Street, Tasty City',
                    style: TextStyle(color: Colors.white),
                  ),
                  const Text(
                    'Phone: +123 456 7890',
                    style: TextStyle(color: Colors.white),
                  ),
                  const Text(
                    'Hours: 10:00 AM - 10 PM',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, {bool isFromDrawer = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Provider.of<AuthProvider>(context, listen: false).signOut();
              if (isFromDrawer) Navigator.of(context).pop(); // Close drawer after logout
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
