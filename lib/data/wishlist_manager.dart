import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class WishlistManager extends ChangeNotifier {
  final Set<String> _ids = {};
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  WishlistManager() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuth);
  }

  void _onAuth(User? user) {
    _sub?.cancel();
    _sub = null;
    _ids.clear();
    if (user != null) {
      _sub = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .snapshots()
          .listen((snap) {
            _ids
              ..clear()
              ..addAll(snap.docs.map((d) => d.id));
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

  int get count => _ids.length;
  List<String> get ids => _ids.toList();
  bool contains(String id) => _ids.contains(id);

  Future<void> toggle(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(id);
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set({'savedAt': FieldValue.serverTimestamp()});
    }
  }
}
