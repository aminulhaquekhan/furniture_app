import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: StreamBuilder<List<String>>(
        stream: fs.getFavoriteProductIds(),
        builder: (context, favSnapshot) {
          if (!favSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final favIds = favSnapshot.data!;
          if (favIds.isEmpty) {
            return const Center(child: Text('No favorites yet'));
          }

          return StreamBuilder<List<Product>>(
            stream: fs.getProducts(),
            builder: (context, productSnapshot) {
              if (!productSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final allProducts = productSnapshot.data!;
              final favProducts = allProducts
                  .where((p) => favIds.contains(p.id))
                  .toList();

              return ListView.builder(
                itemCount: favProducts.length,
                itemBuilder: (context, index) {
                  final p = favProducts[index];
                  return ProductCard(
                    product: p,
                    isFavorite: true,
                    onAddToCart: () => fs.addToCart(p.id),
                    onToggleFavorite: () => fs.removeFromFavorites(p.id),
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
