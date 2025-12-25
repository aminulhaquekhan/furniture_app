import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import 'package:intl/intl.dart';



class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fs.getOrders(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snap.data!;
          if (orders.isEmpty) {
            return const Center(child: Text("No orders yet 😴"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: orders.length,
            itemBuilder: (context, i) {
              final order = orders[i];
              final items = List<Map<String, dynamic>>.from(order['items']);
              final total = order['total'];
              final method = order['paymentMethod'];
              final time = (order['createdAt'] as dynamic)?.toDate();
              final date = time != null
                  ? DateFormat('dd MMM yyyy, h:mm a').format(time)
                  : "Unknown";

              return ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.brown.shade50,
                collapsedBackgroundColor: Colors.brown.shade50,

                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "৳ $total",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Completed",
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
                subtitle: Text(
                  "$method • $date",
                  style: const TextStyle(fontSize: 13),
                ),
                children: [
                  const Divider(),
                  // Product list
                  ...items.map((item) {
                    return ListTile(
                      leading:
                          item["imageUrl"] != null && item["imageUrl"] != ""
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item["imageUrl"],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.image_not_supported),
                      title: Text(item["name"]),
                      subtitle: Text("Quantity: ${item['qty']}"),
                      trailing: Text(
                        "৳ ${item['price']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }),

                  const SizedBox(height: 10),

                  // show Discount
                  if (order['discount'] != null && order['discount'] > 0)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Discount Applied:",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "- ৳ ${order['discount']}",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Final Total:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "৳ ${order['total']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Delivery Section
                  const Text(
                    "Delivery to:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 12),
                    child: Text(
                      "${order['address']['name']} • ${order['address']['phone']}\n${order['address']['address']}",
                      style: const TextStyle(fontSize: 13),
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
