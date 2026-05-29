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
      .map((s) => s.docs
          .where((d) => d.data() != null)
          .map(_docToProduct)
          .toList());

  // ── Private helpers ─────────────────────────────────────────
  Product _docToProduct(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
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
