import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final FirestoreService _fs = FirestoreService();

  ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Expanded(
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        Icons.chair,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '৳ ${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        // favorite button uses streams internally to determine state
                        StreamBuilder<List<String>>(
                          stream: _fs.getFavoriteProductIds(),
                          builder: (context, snap) {
                            final favIds = snap.data ?? [];
                            final isFav = favIds.contains(product.id);
                            return IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : null,
                              ),
                              onPressed: () async {
                                try {
                                  if (isFav) {
                                    await _fs.removeFromFavorites(product.id);
                                    if (context.mounted)
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Removed from favorites',
                                          ),
                                        ),
                                      );
                                  } else {
                                    await _fs.addToFavorites(product.id);
                                    if (context.mounted)
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Added to favorites'),
                                        ),
                                      );
                                  }
                                } catch (e) {
                                  if (context.mounted)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                }
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart_outlined),
                          onPressed: () async {
                            try {
                              await _fs.addToCart(
                                product.id,
                                extra: {
                                  'name': product.name,
                                  'price': product.price,
                                  'imageUrl': product.imageUrl,
                                },
                              );
                              if (context.mounted)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added to cart'),
                                  ),
                                );
                            } catch (e) {
                              if (context.mounted)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error adding to cart: $e'),
                                  ),
                                );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
