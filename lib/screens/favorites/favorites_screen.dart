import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/product.dart';
import '../../data/product_data.dart';
import '../../widgets/product_tile.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  Product _mapDocToProduct(Map<String, dynamic> doc, String docId) {
    // If snapshot fields exist, use them. Otherwise fallback to local catalog by id.
    final name = doc['name'] as String? ?? '';
    final priceRaw = doc['price'];
    final price = (priceRaw is num)
        ? priceRaw.toDouble()
        : (double.tryParse('$priceRaw') ?? 0.0);
    final imageUrl = doc['imageUrl'] as String? ?? '';
    final category = doc['category'] as String? ?? '';

    if (name.isNotEmpty && imageUrl.isNotEmpty) {
      return Product(
        id: docId,
        name: name,
        price: price,
        imageUrl: imageUrl,
        category: category,
      );
    }

    // fallback: try to find in local productCatalog by id or category
    if (productCatalog.containsKey(category)) {
      final found = productCatalog[category]!
          .where((p) => p.id == docId)
          .toList();
      if (found.isNotEmpty) return found.first;
    }
    // fallback: search all keys for matching id
    for (final entry in productCatalog.entries) {
      final found = entry.value.where((p) => p.id == docId).toList();
      if (found.isNotEmpty) return found.first;
    }

    // last fallback: return a minimal Product with placeholder
    return Product(
      id: docId,
      name: name.isNotEmpty ? name : 'Unnamed',
      price: price,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : '',
      category: category.isNotEmpty ? category : 'unknown',
    );
  }

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fs
            .streamFavoriteDocs(), // this returns List<Map> where each map includes id field
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!; // each doc has fields + 'id'
          if (docs.isEmpty) {
            return const Center(child: Text('No favorites yet'));
          }

          final products = docs.map((d) {
            final id = d['id'] ?? '';
            return _mapDocToProduct(d, id);
          }).toList();

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemCount: products.length,
            itemBuilder: (context, i) => ProductTile(product: products[i]),
          );
        },
      ),
    );
  }
}
