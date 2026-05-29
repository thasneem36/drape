import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'models.dart';

/// Holds the signed-in user's profile data and keeps it in sync with
/// Firestore.  Exposed via Provider so ProfileScreen and CheckoutScreen
/// can read addresses / payments without a FutureBuilder.
class UserProfileManager extends ChangeNotifier {
  String name = '';
  String email = '';
  String phone = '';
  List<Address> addresses = [];
  List<Payment> payments = [];

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  UserProfileManager() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuth);
  }

  void _onAuth(User? user) {
    _sub?.cancel();
    _sub = null;
    if (user != null) {
      email = user.email ?? '';
      name = user.displayName ?? '';
      _sub = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((doc) {
            if (doc.exists) {
              final d = doc.data()!;
              name = (d['name'] as String?) ?? user.displayName ?? '';
              email = (d['email'] as String?) ?? user.email ?? '';
              phone = (d['phone'] as String?) ?? '';
              addresses = ((d['addresses'] as List<dynamic>?) ?? [])
                  .map<Address>((a) =>
                      Address.fromMap(Map<String, dynamic>.from(a as Map)))
                  .toList();
              payments = ((d['payments'] as List<dynamic>?) ?? [])
                  .map<Payment>((p) =>
                      Payment.fromMap(Map<String, dynamic>.from(p as Map)))
                  .toList();
            } else {
              name = user.displayName ?? '';
              email = user.email ?? '';
            }
            notifyListeners();
          });
    } else {
      name = '';
      email = '';
      phone = '';
      addresses = [];
      payments = [];
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> save({String? name, String? email, String? phone}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (phone != null) updates['phone'] = phone;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(updates, SetOptions(merge: true));
    if (name != null) {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
    }
  }

  // ── Addresses ─────────────────────────────────────────────────

  Future<void> addAddress(Address addr) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    // If this address is default, clear default on all others first.
    final updated = addr.isDefault
        ? addresses.map((a) => Address(a.label, a.line1, a.line2)).toList()
        : List<Address>.from(addresses);
    updated.add(addr);
    await _writeAddresses(uid, updated);
  }

  Future<void> removeAddress(int index) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final updated = List<Address>.from(addresses)..removeAt(index);
    await _writeAddresses(uid, updated);
  }

  Future<void> _writeAddresses(
      String uid, List<Address> list) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'addresses': list.map((a) => a.toMap()).toList()});
  }

  // ── Payments ──────────────────────────────────────────────────

  Future<void> addPayment(Payment payment) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final updated = List<Payment>.from(payments)..add(payment);
    await _writePayments(uid, updated);
  }

  Future<void> removePayment(int index) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final updated = List<Payment>.from(payments)..removeAt(index);
    await _writePayments(uid, updated);
  }

  Future<void> _writePayments(
      String uid, List<Payment> list) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'payments': list.map((p) => p.toMap()).toList()});
  }
}
