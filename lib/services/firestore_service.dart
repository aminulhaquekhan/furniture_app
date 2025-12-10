import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ----------------- PRODUCTS -----------------
  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((d) => Product.fromMap(d.id, d.data())).toList();
    });
  }

  // ----------------- USER BASIC INFO (PROFILE DOC) -----------------
  // signup done হওয়ার পর user এর name/phone এবং email রাখার জন্য
  Future<void> saveUserProfile({
    required String name,
    required String phone,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;
    await _db.collection('users').doc(user.uid).set({
      'email': user.email,
      'name': name,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ----------------- ADDRESS (PROFILE/INFO SUBCOLLECTION) -----------------
  Future<void> saveAddress({
    required String name,
    required String phone,
    required String address,
  }) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('profile')
        .doc('info')
        .set({
          'name': name,
          'phone': phone,
          'address': address,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> getAddress() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('profile')
        .doc('info')
        .snapshots()
        .map((doc) => doc.data());
  }

  // ----------------- CART -----------------
  Future<void> addToCart(String productId) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .doc(productId)
        .set({'added': true, 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> removeFromCart(String productId) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  Stream<List<String>> getCartProductIds() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .snapshots()
        .map((s) => s.docs.map((d) => d.id).toList());
  }

  Future<void> clearCart() async {
    final cartRef = _db.collection('users').doc(_uid).collection('cart');
    final snap = await cartRef.get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // ----------------- FAVORITES -----------------
  Future<void> addToFavorites(String productId) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .doc(productId)
        .set({'fav': true});
  }

  Future<void> removeFromFavorites(String productId) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .doc(productId)
        .delete();
  }

  Stream<List<String>> getFavoriteProductIds() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .snapshots()
        .map((s) => s.docs.map((d) => d.id).toList());
  }

  // ----------------- ORDERS (TRANSACTIONS) -----------------
  // এখানে প্রতিটা order user এর নিচে orders subcollection এ সেভ হবে
  Future<void> createOrder({
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String paymentMethod, // example: "cash_on_delivery"
  }) {
    final ordersRef = _db.collection('users').doc(_uid).collection('orders');

    return ordersRef.add({
      'items': items,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
