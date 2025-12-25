import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
// import 'payment_success_screen.dart'; // enable when you add success page

class CheckoutScreen extends StatefulWidget {
  final double total;
  final List<Map<String, dynamic>> items;

  const CheckoutScreen({super.key, required this.total, required this.items});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final FirestoreService fs = FirestoreService();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final promoCtrl = TextEditingController();

  String paymentMethod = 'Card';
  bool loading = false;

  double discount = 0;
  double finalTotal = 0;

  // Payment field controllers
  final cardCtrl = TextEditingController();
  final expCtrl = TextEditingController();
  final cvvCtrl = TextEditingController();

  final bkashCtrl = TextEditingController();
  final bkashOtpCtrl = TextEditingController();
  final bkashPinCtrl = TextEditingController();

  final nagadCtrl = TextEditingController();
  final nagadPinCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    finalTotal = widget.total;
  }

  /// APPLY PROMO
  void applyPromo() {
    if (promoCtrl.text.trim() == "TMR5") {
      discount = widget.total * 0.05;
      finalTotal = widget.total - discount;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Promo Applied Successfully (5% OFF)")),
      );
    } else {
      discount = 0;
      finalTotal = widget.total;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid Promo Code")));
    }
    setState(() {});
  }

  /// PLACE ORDER
  Future<void> _placeOrder() async {
    if (nameCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty ||
        addressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Fill address info')));
      return;
    }

    setState(() => loading = true);

    await fs.createOrder(
      items: widget.items,
      total: finalTotal,
      discount: discount,
      paymentMethod: paymentMethod,
      address: {
        'name': nameCtrl.text,
        'phone': phoneCtrl.text,
        'address': addressCtrl.text,
      },
    );

    if (!mounted) return;
    setState(() => loading = false);

    // Change to success screen if needed
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order Confirmed Successfully')),
    );

    // For success screen enable this ↓
    // Navigator.pushReplacement(context, MaterialPageRoute(
    //   builder: (_) => const PaymentSuccessScreen(),
    // ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Address
            const Text(
              "Delivery Address",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(labelText: 'Full Address'),
              maxLines: 2,
            ),

            const SizedBox(height: 20),

            /// Promo Code
            const Text(
              "Promo Code",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: promoCtrl,
                    decoration: const InputDecoration(hintText: "Enter Promo"),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: applyPromo,
                  child: const Text("Apply"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Payment Method
            const Text(
              "Payment Method",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            RadioListTile(
              title: const Text("Card"),
              value: "Card",
              groupValue: paymentMethod,
              onChanged: (v) => setState(() => paymentMethod = v!),
            ),
            RadioListTile(
              title: const Text("bKash"),
              value: "bKash",
              groupValue: paymentMethod,
              onChanged: (v) => setState(() => paymentMethod = v!),
            ),
            RadioListTile(
              title: const Text("Nagad"),
              value: "Nagad",
              groupValue: paymentMethod,
              onChanged: (v) => setState(() => paymentMethod = v!),
            ),

            const SizedBox(height: 10),

            /// Payment UI — appears based on selection
            if (paymentMethod == "Card") ...[
              const Text(
                "Card Payment Info",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: cardCtrl,
                decoration: const InputDecoration(labelText: "Card Number"),
              ),
              TextField(
                controller: expCtrl,
                decoration: const InputDecoration(labelText: "MM/YY"),
              ),
              TextField(
                controller: cvvCtrl,
                decoration: const InputDecoration(labelText: "CVV"),
                obscureText: true,
                keyboardType: TextInputType.number,
              ),
            ],
            if (paymentMethod == "bKash") ...[
              const Text(
                "bKash Payment",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: bkashCtrl,
                decoration: const InputDecoration(labelText: "bKash Number"),
              ),
              TextField(
                controller: bkashOtpCtrl,
                decoration: const InputDecoration(labelText: "OTP Code"),
              ),
              TextField(
                controller: bkashPinCtrl,
                decoration: const InputDecoration(labelText: "PIN"),
                obscureText: true,
              ),
            ],
            if (paymentMethod == "Nagad") ...[
              const Text(
                "Nagad Payment",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: nagadCtrl,
                decoration: const InputDecoration(labelText: "Nagad Number"),
              ),
              TextField(
                controller: bkashOtpCtrl,
                decoration: const InputDecoration(labelText: "OTP Code"),
              ),
              TextField(
                controller: nagadPinCtrl,
                decoration: const InputDecoration(labelText: "PIN"),
                obscureText: true,
              ),
            ],

            const SizedBox(height: 20),

            /// Totals
            Text(
              "Subtotal: ৳ ${widget.total}",
              style: const TextStyle(fontSize: 16),
            ),
            if (discount > 0)
              Text(
                "Discount: -৳ ${discount.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            Text(
              "Final Payable: ৳ ${finalTotal.toStringAsFixed(0)}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _placeOrder,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        "Confirm Payment",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
