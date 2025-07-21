import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/menu_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white, // White background
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: const Text(
            'Menu',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Starters'),
              Tab(text: 'Main Courses'),
              Tab(text: 'Desserts'),
              Tab(text: 'Drinks'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MenuCategory(category: 'Starters'),
            MenuCategory(category: 'Main Courses'),
            MenuCategory(category: 'Desserts'),
            MenuCategory(category: 'Drinks'),
          ],
        ),
      ),
    );
  }
}

class MenuCategory extends StatelessWidget {
  final String category;

  const MenuCategory({Key? key, required this.category}) : super(key: key);

  void _showItemDetails(BuildContext context, String itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          content: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('menu').doc(itemId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final item = snapshot.data!;
              return SingleChildScrollView(
                child: MenuCard(
                  id: item.id,
                  name: item['name'] ?? 'Unknown Dish',
                  description: item['description'] ?? 'No description',
                  price: (item['price'] ?? 0.0).toDouble(),
                  imageUrl: item['imageUrl'] ?? 'https://via.placeholder.com/150',
                  likes: item['likes'] ?? 0,
                  dislikes: item['dislikes'] ?? 0,
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('menu')
          .where('category', isEqualTo: category)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!.docs;
        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.75,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () => _showItemDetails(context, item.id),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.redAccent.withOpacity(0.5), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      child: CachedNetworkImage(
                        imageUrl: item['imageUrl'] ?? 'https://via.placeholder.com/150',
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item['name'] ?? 'Unknown Dish',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '\$${(item['price'] ?? 0.0).toDouble().toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
