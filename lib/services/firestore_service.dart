import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;





  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No logged-in user. Please login first.',
      );
    }
    return user.uid;
  }

  // ---------------- Products ----------------
  Stream<List<Product>> getProducts() {
    return _db
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Product.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<List<Product>> getProductsByCategory(String category) {
    return _db
        .collection('products')
        .where('category', isEqualTo: category)
        .limit(50)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Product.fromMap(d.id, d.data())).toList(),
        );
  }

  // ---------------- Cart ----------------
  Future<void> addToCart(
    String productId, {
    Map<String, dynamic>? extra,
  }) async {
    final docRef = _db
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .doc(productId);

    // Use transaction so we both write the snapshot and increment safely
    await _db.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      if (!snapshot.exists) {
        final data = {
          'quantity': 1,
          'createdAt': FieldValue.serverTimestamp(),
          if (extra != null) ...extra,
        };
        tx.set(docRef, data, SetOptions(merge: true));
      } else {
        // increment quantity by 1
        tx.update(docRef, {'quantity': FieldValue.increment(1)});
        // also merge snapshot fields if provided
        if (extra != null) {
          tx.update(docRef, extra);
        }
      }
    });
  }

  // Decrement quantity: if quantity > 1 decrement, else delete doc
  Future<void> decrementCartItem(String productId) async {
    final docRef = _db
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .doc(productId);

    await _db.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      final currentQty = (data['quantity'] ?? 0) as num;
      if (currentQty > 1) {
        tx.update(docRef, {'quantity': FieldValue.increment(-1)});
      } else {
        tx.delete(docRef);
      }
    });
  }

  // Remove from cart
  Future<void> removeFromCart(String productId) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  // Stream of cart documents with their data (not only ids)
  Stream<List<Map<String, dynamic>>> streamCartDocs() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final m = d.data();
            m['id'] = d.id;
            return m;
          }).toList(),
        );
  }

  Stream<List<String>> getCartProductIds() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }

  Future<void> clearCart() async {
    final ref = _db.collection('users').doc(_uid).collection('cart');
    final snap = await ref.get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // ---------------- Favorites ----------------
  // Add to favorites (store snapshot too)
  Future<void> addToFavorites(String productId, {Map<String, dynamic>? extra}) {
    final docRef = _db
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .doc(productId);
    final data = {
      'fav': true,
      'createdAt': FieldValue.serverTimestamp(),
      if (extra != null) ...extra,
    };
    return docRef.set(data, SetOptions(merge: true));
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
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }

  // Stream of favorite documents with their data
  Stream<List<Map<String, dynamic>>> streamFavoriteDocs() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final m = d.data();
            m['id'] = d.id;
            return m;
          }).toList(),
        );
  }

  // ---------------- Profile ----------------
  Future<void> saveUserProfile({required String name, required String phone}) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No logged-in user. Please login first.',
      );
    }

    return _db.collection('users').doc(user.uid).set({
      'email': user.email,
      'name': name,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ---------------- Address (save & get) ----------------
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
        .map((d) => d.data());
  }

  /// Seed default products for a category if none exist.
  /// This is idempotent: it only seeds when the category has zero docs.
  Future<void> seedDefaultProductsForCategory(
    String category, {
    int count = 50,
  }) async {
    final coll = _db.collection('products');
    final q = await coll.where('category', isEqualTo: category).limit(1).get();
    if (q.docs.isNotEmpty) {
      // already has at least one product -> do not seed
      return;
    }

    final batch = _db.batch();
    for (int i = 0; i < count; i++) {
      final docRef = coll.doc(); // auto id
      batch.set(docRef, {
        'name':
            '${category[0].toUpperCase()}${category.substring(1)} Item ${i + 1}',
        'price': (800 + (i % 20) * 50).toDouble(), // sample price pattern
        'imageUrl': '', // leave empty or provide default URL
        'category': category,
        'createdAt': FieldValue.serverTimestamp(),
        // optional: add short description, stock, etc.
        'description': 'Default $category product #${i + 1}',
      });
    }

    await batch.commit();
  }

  // create order
  Future<void> createOrder({
    required List<Map<String, dynamic>> items,
    required double total,
    required String paymentMethod,
    required Map<String, String> address,
    double discount = 0, // <--- Add
  }) async {
    await _db.collection('users').doc(_uid).collection('orders').add({
      'items': items,
      'total': total,
      'discount': discount, // <--- Store discount
      'paymentMethod': paymentMethod,
      'address': address,
      'status': 'completed',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await clearCart();
  }


  // get orders
  Stream<List<Map<String, dynamic>>> getOrders() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }



}
