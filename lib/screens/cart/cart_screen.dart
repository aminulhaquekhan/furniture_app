import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: StreamBuilder<List<String>>(
        stream: fs.getCartProductIds(),
        builder: (context, cartSnapshot) {
          if (!cartSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartIds = cartSnapshot.data!;
          if (cartIds.isEmpty) {
            return const Center(child: Text('Cart is empty'));
          }

          return StreamBuilder<List<Product>>(
            stream: fs.getProducts(),
            builder: (context, productSnapshot) {
              if (!productSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final allProducts = productSnapshot.data!;
              final cartProducts = allProducts
                  .where((p) => cartIds.contains(p.id))
                  .toList();

              double total = 0;
              for (final p in cartProducts) {
                total += p.price;
              }

              Future<void> _checkout() async {
                // items list transaction er jonno
                final items = cartProducts
                    .map(
                      (p) => {
                        'productId': p.id,
                        'name': p.name,
                        'price': p.price,
                        'qty': 1, // ekhane quantity 1 ধরা হল
                      },
                    )
                    .toList();

                // Firestore e order/transaction save
                await fs.createOrder(
                  items: items,
                  totalAmount: total,
                  paymentMethod: 'cash_on_delivery',
                );

                // Cart clear kore dewa
                await fs.clearCart();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order placed successfully')),
                  );
                }
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartProducts.length,
                      itemBuilder: (context, index) {
                        final p = cartProducts[index];
                        return ProductCard(
                          product: p,
                          isFavorite: false,
                          onAddToCart: () => fs.removeFromCart(p.id),
                          onToggleFavorite: () {},
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total: ৳ ${total.toStringAsFixed(0)}'),
                        FilledButton(
                          onPressed: _checkout,
                          child: const Text('Checkout'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
