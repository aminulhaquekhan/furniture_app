import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =================== UID Getter ===================
  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-logged-in',
        message: 'User not logged in.',
      );
    }
    return user.uid;
  }

  // =================== PRODUCTS ===================
  Stream<List<Product>> getProducts() {
    return _db
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (e) => e.docs.map((d) => Product.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<List<Product>> getProductsByCategory(String category) {
    return _db
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map(
          (e) => e.docs.map((d) => Product.fromMap(d.id, d.data())).toList(),
        );
  }

  // =================== CART ===================
  Future<void> addToCart(
    String productId, {
    Map<String, dynamic>? extra,
  }) async {
    final ref = _db
        .collection("users")
        .doc(_uid)
        .collection("cart")
        .doc(productId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);

      if (!snap.exists) {
        tx.set(ref, {
          "quantity": 1,
          "createdAt": FieldValue.serverTimestamp(),
          if (extra != null) ...extra,
        });
      } else {
        tx.update(ref, {"quantity": FieldValue.increment(1)});
        if (extra != null) tx.update(ref, extra);
      }
    });
  }

  Future<void> decrementCartItem(String productId) async {
    final ref = _db
        .collection("users")
        .doc(_uid)
        .collection("cart")
        .doc(productId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;

      final q = snap.data()!['quantity'] ?? 0;
      q > 1
          ? tx.update(ref, {"quantity": FieldValue.increment(-1)})
          : tx.delete(ref);
    });
  }

  Future<void> removeFromCart(String productId) => _db
      .collection("users")
      .doc(_uid)
      .collection("cart")
      .doc(productId)
      .delete();

  Stream<List<Map<String, dynamic>>> streamCartDocs() {
    return _db
        .collection("users")
        .doc(_uid)
        .collection("cart")
        .snapshots()
        .map(
          (e) => e.docs.map((d) {
            final m = d.data();
            m['id'] = d.id;
            return m;
          }).toList(),
        );
  }

  Future<void> clearCart() async {
    final ref = _db.collection("users").doc(_uid).collection("cart");
    final docs = await ref.get();
    for (var d in docs.docs) {
      await d.reference.delete();
    }
  }

  // =================== FAVORITES ===================
  Future<void> addToFavorites(String productId, {Map<String, dynamic>? extra}) {
    return _db
        .collection("users")
        .doc(_uid)
        .collection("favorites")
        .doc(productId)
        .set({
          "fav": true,
          "createdAt": FieldValue.serverTimestamp(),
          if (extra != null) ...extra,
        }, SetOptions(merge: true));
  }

  Future<void> removeFromFavorites(String productId) => _db
      .collection("users")
      .doc(_uid)
      .collection("favorites")
      .doc(productId)
      .delete();

  Stream<List<Map<String, dynamic>>> streamFavoriteDocs() {
    return _db
        .collection("users")
        .doc(_uid)
        .collection("favorites")
        .snapshots()
        .map(
          (e) => e.docs.map((d) {
            final m = d.data();
            m['id'] = d.id;
            return m;
          }).toList(),
        );
  }

  // =================== PROFILE ===================
  Future<void> saveUserProfile({
    required String name,
    required String phone,
  }) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) throw Exception("Login first");

    return _db.collection("users").doc(u.uid).set({
      "email": u.email,
      "name": name,
      "phone": phone,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // =================== ADDRESS ===================
  Future<void> saveAddress({
    required String name,
    required String phone,
    required String address,
  }) {
    return _db
        .collection("users")
        .doc(_uid)
        .collection("profile")
        .doc("info")
        .set({
          "name": name,
          "phone": phone,
          "address": address,
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> getAddress() {
    return _db
        .collection("users")
        .doc(_uid)
        .collection("profile")
        .doc("info")
        .snapshots()
        .map((d) => d.data());
  }

  // =================== ORDERS ===================
  Future<void> createOrder({
    required List items,
    required double total,
    required String paymentMethod,
    required Map address,
    double discount = 0,
  }) async {
    await _db.collection("users").doc(_uid).collection("orders").add({
      "items": items,
      "total": total,
      "discount": discount,
      "paymentMethod": paymentMethod,
      "address": address,
      "createdAt": FieldValue.serverTimestamp(),
      "status": "Completed",
    });

    await clearCart();
  }

  Stream<List<Map<String, dynamic>>> getOrders() {
    return _db
        .collection("users")
        .doc(_uid)
        .collection("orders")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((e) => e.docs.map((d) => d.data()).toList());
  }
}
