import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class ContactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text(
          'Contact / About',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About Us',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Welcome to our family-owned restaurant, serving delicious and authentic meals since 2000. '
                    'Our passion is to bring you fresh, quality food made with love and the finest ingredients. '
                    'Whether you join us for a casual lunch or a special dinner, we aim to make every visit memorable.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Address: 123 Food Street, Tasty City',
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                'Phone: +123 456 7890',
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                'Email: contact@restaurant.com',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                'Opening Hours',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Monday - Friday: 10:00 AM - 10:00 PM',
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                'Saturday - Sunday: 11:00 AM - 11:00 PM',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                'Follow Us',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.facebook, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('facebook.com/ourrestaurant', style: TextStyle(fontSize: 16)),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(FontAwesomeIcons.instagram, color: Colors.purple),
                  SizedBox(width: 8),
                  Text('instagram.com/ourrestaurant', style: TextStyle(fontSize: 16)),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
