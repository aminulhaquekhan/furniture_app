import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Furniture')),
      body: StreamBuilder<List<Product>>(
        stream: fs.getProducts(),
        builder: (context, productSnapshot) {
          if (!productSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = productSnapshot.data!;
          if (products.isEmpty) {
            return const Center(child: Text('No products yet'));
          }

          return StreamBuilder<List<String>>(
            stream: fs.getFavoriteProductIds(),
            builder: (context, favSnapshot) {
              final favIds = favSnapshot.data ?? [];

              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final p = products[index];
                  final isFav = favIds.contains(p.id);

                  return ProductCard(
                    product: p,
                    isFavorite: isFav,
                    onAddToCart: () => fs.addToCart(p.id),
                    onToggleFavorite: () {
                      if (isFav) {
                        fs.removeFromFavorites(p.id);
                      } else {
                        fs.addToFavorites(p.id);
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
