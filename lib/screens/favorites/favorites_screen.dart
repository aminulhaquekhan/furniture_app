import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/product.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: StreamBuilder<List<String>>(
        stream: fs.getFavoriteProductIds(),
        builder: (context, favSnap) {
          if (!favSnap.hasData)
            return const Center(child: CircularProgressIndicator());
          final favIds = favSnap.data!;
          if (favIds.isEmpty)
            return const Center(child: Text('No favorites yet'));

          return StreamBuilder<List<Product>>(
            stream: fs.getProducts(),
            builder: (context, prodSnap) {
              if (!prodSnap.hasData)
                return const Center(child: CircularProgressIndicator());
              final all = prodSnap.data!;
              final favProducts = all
                  .where((p) => favIds.contains(p.id))
                  .toList();

              return ListView.builder(
                itemCount: favProducts.length,
                itemBuilder: (context, i) {
                  final p = favProducts[i];
                  return ListTile(
                    leading: p.imageUrl.isNotEmpty
                        ? Image.network(
                            p.imageUrl,
                            width: 60,
                            fit: BoxFit.cover,
                          )
                        : null,
                    title: Text(p.name),
                    subtitle: Text('৳ ${p.price.toStringAsFixed(0)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart),
                          onPressed: () => fs.addToCart(p.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => fs.removeFromFavorites(p.id),
                        ),
                      ],
                    ),
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
