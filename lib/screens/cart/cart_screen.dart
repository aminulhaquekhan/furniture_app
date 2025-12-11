import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/product.dart';
import '../../widgets/product_tile.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: StreamBuilder<List<String>>(
        stream: fs.getCartProductIds(),
        builder: (context, cartSnap) {
          if (!cartSnap.hasData)
            return const Center(child: CircularProgressIndicator());
          final cartIds = cartSnap.data!;
          if (cartIds.isEmpty)
            return const Center(child: Text('Cart is empty'));

          // get all products and filter
          return StreamBuilder<List<Product>>(
            stream: fs.getProducts(),
            builder: (context, prodSnap) {
              if (!prodSnap.hasData)
                return const Center(child: CircularProgressIndicator());
              final all = prodSnap.data!;
              final cartProducts = all
                  .where((p) => cartIds.contains(p.id))
                  .toList();

              double total = 0;
              for (final p in cartProducts) total += p.price;

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartProducts.length,
                      itemBuilder: (context, i) {
                        final p = cartProducts[i];
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
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => fs.removeFromCart(p.id),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: ৳ ${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FilledButton(
                          onPressed: () async {
                            // Here you can implement checkout/order creation
                            final items = cartProducts
                                .map(
                                  (p) => {
                                    'productId': p.id,
                                    'name': p.name,
                                    'price': p.price,
                                    'qty': 1,
                                  },
                                )
                                .toList();
                            await fs.createOrder(
                              items: items,
                              totalAmount: total,
                              paymentMethod: 'cash_on_delivery',
                            );
                            await fs.clearCart();
                            if (context.mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Order placed')),
                              );
                          },
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
