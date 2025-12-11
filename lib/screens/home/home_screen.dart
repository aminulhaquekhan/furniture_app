import 'package:flutter/material.dart';
import '../product/product_list_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<Map<String, String>> categories = [
    {'id': 'chairs', 'label': 'Chairs'},
    {'id': 'sofa', 'label': 'Sofas'},
    {'id': 'table', 'label': 'Tables'},
    {'id': 'bed', 'label': 'Beds'},
    {'id': 'decor', 'label': 'Decor'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Furniture')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = categories[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductListScreen(category: cat['id']!),
                      ),
                    );
                  },
                  child: Chip(
                    label: Text(cat['label']!),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Recommended',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          // You can show some recommended products or recent items here
          Expanded(
            child: Center(
              child: Text('Select a category above to view products'),
            ),
          ),
        ],
      ),
    );
  }
}
