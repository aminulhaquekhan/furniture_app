import 'package:flutter/material.dart';
import '../../data/product_data.dart';
import '../../widgets/product_tile.dart';

class ProductListScreen extends StatelessWidget {
  final String category;

  const ProductListScreen({super.key, required this.category});

  List<String> _possibleKeys(String raw) {
    final base = raw.toLowerCase().trim();
    // try direct, plural 's', plural 'es' and a couple common synonyms
    return <String>[
      base,
      '${base}s',
      '${base}es',
      // synonyms mapping for common variants
      if (base == 'sofa') 'sofas',
      if (base == 'table') 'tables',
      if (base == 'bed') 'beds',
      if (base == 'chair') 'chairs',
    ].toSet().toList(); // uniq
  }

  @override
  Widget build(BuildContext context) {
    final keys = _possibleKeys(category);
    List products = [];
    for (final k in keys) {
      final p = productCatalog[k];
      if (p != null && p.isNotEmpty) {
        products = p;
        break;
      }
    }

    // debug prints (optional) — remove later
    debugPrint(
      'Requested category: $category -> tried keys: $keys -> found: ${products.length}',
    );

    return Scaffold(
      appBar: AppBar(title: Text(category.toUpperCase())),
      body: products.isEmpty
          ? const Center(child: Text("No products in this category"))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductTile(product: products[index]);
              },
            ),
    );
  }
}
