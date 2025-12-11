import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/product.dart';
import '../../widgets/product_tile.dart';

class ProductListScreen extends StatefulWidget {
  final String category;
  const ProductListScreen({super.key, required this.category});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final FirestoreService _fs = FirestoreService();
  bool _seeding = true;
  String? _seedError;

  @override
  void initState() {
    super.initState();
    _ensureSeeded();
  }

  Future<void> _ensureSeeded() async {
    try {
      setState(() {
        _seeding = true;
        _seedError = null;
      });
      // only seed if category empty
      await _fs.seedDefaultProductsForCategory(widget.category, count: 50);
    } catch (e) {
      _seedError = e.toString();
    } finally {
      if (mounted) {
        setState(() => _seeding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_seeding) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.category.toUpperCase())),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_seedError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.category.toUpperCase())),
        body: Center(child: Text('Seed error: $_seedError')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.toUpperCase())),
      body: StreamBuilder<List<Product>>(
        stream: _fs.getProductsByCategory(widget.category),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snap.data ?? [];
          if (products.isEmpty) {
            return const Center(child: Text('No products found'));
          }
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
