import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'models.dart';

class OrderManager extends ChangeNotifier {
  final List<Order> _orders = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  OrderManager() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuth);
  }

  void _onAuth(User? user) {
    _sub?.cancel();
    _sub = null;
    _orders.clear();
    if (user != null) {
      _sub = FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snap) {
            _orders
              ..clear()
              ..addAll(snap.docs
                  .map((d) => Order.fromFirestore(d.id, d.data())));
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

  List<Order> get orders => List.unmodifiable(_orders);
  int get count => _orders.length;

  /// Places the order and returns the new Firestore document ID.
  Future<String> placeOrder(
    List<CartItem> items,
    String address,
    double total,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return '';
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dateStr =
        '${months[now.month - 1]} ${now.day.toString().padLeft(2, '0')}, ${now.year}';
    final ref = await FirebaseFirestore.instance.collection('orders').add({
      'userId': uid,
      'dateStr': dateStr,
      'status': 'Processing',
      'totalPrice': total,
      'address': address,
      'items': items
          .map((i) => {
                'productId': i.productId,
                'name':      i.name,
                'brand':     i.brand,
                'size':      i.size,
                'color':     i.color,
                'qty':       i.qty,
                'price':     i.price,
                'imageUrl':  i.imageUrl,
              })
          .toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}
