import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleFavorite;
  final bool isFavorite;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onToggleFavorite,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: product.imageUrl.isNotEmpty
              ? Image.network(product.imageUrl, width: 60, fit: BoxFit.cover)
              : const Icon(Icons.chair),
        ),
        title: Text(product.name),
        subtitle: Text('৳ ${product.price.toStringAsFixed(0)}'),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_outline),
              onPressed: onToggleFavorite,
            ),
            IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: onAddToCart,
            ),
          ],
        ),
      ),
    );
  }
}
