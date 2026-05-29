import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'models.dart';

class CartManager extends ChangeNotifier {
  final List<CartItem> _items = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  CartManager() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuth);
  }

  void _onAuth(User? user) {
    _sub?.cancel();
    _sub = null;
    _items.clear();
    if (user != null) {
      _sub = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .orderBy('addedAt')
          .snapshots()
          .listen((snap) {
            _items
              ..clear()
              ..addAll(snap.docs
                  .map((d) => CartItem.fromFirestore(d.id, d.data())));
            notifyListeners();
          });
    } else {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (a, b) => a + b.qty);
  double subtotal() =>
      _items.fold(0.0, (a, i) => a + i.price * i.qty);

  Future<void> add(
    Product p,
    String size,
    String color, {
    int qty = 1,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart');
    final existing = await ref
        .where('productId', isEqualTo: p.id)
        .where('size', isEqualTo: size)
        .where('color', isEqualTo: color)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      final current = (doc.data()['qty'] as int?) ?? 1;
      await doc.reference.update({'qty': current + qty});
    } else {
      await ref.add({
        'productId': p.id,
        'name': p.name,
        'brand': p.brand,
        'price': p.price,
        'imageUrl': p.imageUrl,
        'size': size,
        'color': color,
        'qty': qty,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> removeAt(int i) async {
    if (i < 0 || i >= _items.length) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(_items[i].docId)
        .delete();
  }

  Future<void> setQty(int i, int qty) async {
    if (i < 0 || i >= _items.length) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(_items[i].docId)
        .update({'qty': qty.clamp(1, 99)});
  }

  Future<void> clear() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
