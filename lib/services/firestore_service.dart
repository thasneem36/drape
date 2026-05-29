// ─────────────────────────────────────────────────────────────
// FirestoreService — single access point for all Firestore ops.
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Products ────────────────────────────────────────────────
  Stream<List<Product>> getProducts() => _db
      .collection('products')
      .snapshots()
      .map((s) => s.docs.map(_docToProduct).toList());

  Stream<List<Product>> getProductsByCategory(String category) => _db
      .collection('products')
      .where('cat', isEqualTo: category)
      .snapshots()
      .map((s) => s.docs.map(_docToProduct).toList());

  // ── Cart ────────────────────────────────────────────────────
  Future<void> addToCart(
    String userId,
    CartItem item, {
    String name = '',
    String brand = '',
    double price = 0.0,
    String imageUrl = '',
  }) async {
    final ref =
        _db.collection('users').doc(userId).collection('cart');
    final existing = await ref
        .where('productId', isEqualTo: item.productId)
        .where('size', isEqualTo: item.size)
        .where('color', isEqualTo: item.color)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      final currentQty = (doc.data()['qty'] as int?) ?? 1;
      await doc.reference.update({'qty': currentQty + item.qty});
    } else {
      await ref.add({
        'productId': item.productId,
        'name': name,
        'brand': brand,
        'price': price,
        'imageUrl': imageUrl,
        'size': item.size,
        'color': item.color,
        'qty': item.qty,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> cartSnapStream(
          String uid) =>
      _db.collection('users').doc(uid).collection('cart').snapshots();

  Future<void> removeCartItem(String uid, String docId) => _db
      .collection('users')
      .doc(uid)
      .collection('cart')
      .doc(docId)
      .delete();

  Future<void> setCartItemQty(String uid, String docId, int qty) => _db
      .collection('users')
      .doc(uid)
      .collection('cart')
      .doc(docId)
      .update({'qty': qty});

  Future<void> clearCart(String uid) async {
    final batch = _db.batch();
    final snap =
        await _db.collection('users').doc(uid).collection('cart').get();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ── Orders ──────────────────────────────────────────────────
  Future<String> placeOrder(Map<String, dynamic> orderData) async {
    final data = {
      'status': 'Processing',
      ...orderData,
      'createdAt': FieldValue.serverTimestamp(),
    };
    final ref = await _db.collection('orders').add(data);
    return ref.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> ordersSnapStream(
          String uid) =>
      _db
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots();

  // ── User Profile ────────────────────────────────────────────
  Future<void> saveUserProfile(
    String userId,
    Map<String, dynamic> userData,
  ) =>
      _db.collection('users').doc(userId).set(
            {...userData, 'updatedAt': FieldValue.serverTimestamp()},
            SetOptions(merge: true),
          );

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userDocStream(
          String uid) =>
      _db.collection('users').doc(uid).snapshots();

  // ── Wishlist ────────────────────────────────────────────────
  Stream<Set<String>> wishlistIdsStream(String uid) => _db
      .collection('users')
      .doc(uid)
      .collection('wishlist')
      .snapshots()
      .map((s) => s.docs.map((d) => d.id).toSet());

  Future<void> toggleWishlist(String uid, String productId) async {
    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(productId);
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set({'savedAt': FieldValue.serverTimestamp()});
    }
  }

  // ── Private helpers ─────────────────────────────────────────
  Product _docToProduct(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Product(
      id: doc.id,
      name: (d['name'] as String?) ?? '',
      brand: (d['brand'] as String?) ?? '',
      price: (d['price'] as num?)?.toDouble() ?? 0.0,
      cat: (d['cat'] as String?) ?? '',
      desc: (d['desc'] as String?) ?? '',
      sizes: List<String>.from(d['sizes'] ?? []),
      colors: List<String>.from(d['colors'] ?? []),
      rating: (d['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: (d['reviews'] as int?) ?? 0,
      tint: List<int>.from(d['tint'] ?? [0xFF1A1816, 0xFF1A1816]),
      art: (d['art'] as String?) ?? '',
      imageUrl: (d['imageUrl'] as String?) ?? '',
      isNew: (d['isNew'] as bool?) ?? false,
      isSale: (d['isSale'] as bool?) ?? false,
    );
  }
}
