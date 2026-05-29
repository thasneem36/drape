// ─────────────────────────────────────────────────────────────
// NotificationPrefsManager — shared ChangeNotifier for push-
// notification preferences.
//
// Consumed by:
//   • NotificationsScreen  — toggle switches
//   • HomeScreen bell icon — active vs. muted state
//
// Firestore path: users/{uid}.notifPrefs
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class NotificationPrefsManager extends ChangeNotifier {
  static const _keys = [
    'orderUpdates',
    'newArrivals',
    'salesOffers',
    'wishlistAlerts',
  ];

  final Map<String, bool> _prefs = {
    for (final k in _keys) k: true,
  };

  bool _loading = true;

  NotificationPrefsManager() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuth);
  }

  // ── Public API ────────────────────────────────────────────

  bool get loading => _loading;

  /// True when at least one notification type is enabled.
  bool get anyEnabled => _prefs.values.any((v) => v);

  /// True when every notification type is disabled.
  bool get allDisabled => _prefs.values.every((v) => !v);

  /// Unmodifiable copy of the full prefs map.
  Map<String, bool> get prefs => Map.unmodifiable(_prefs);

  bool valueOf(String key) => _prefs[key] ?? true;

  /// Toggle a single preference and persist to Firestore.
  Future<void> toggle(String key, bool val) async {
    if (!_keys.contains(key)) return;
    _prefs[key] = val;
    notifyListeners(); // instant local update

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(
            {'notifPrefs': Map<String, bool>.from(_prefs)},
            SetOptions(merge: true),
          );
    } catch (_) {}
  }

  // ── Internal ──────────────────────────────────────────────

  void _onAuth(User? user) {
    if (user != null) {
      _load(user.uid);
    } else {
      // Signed out — reset to defaults
      for (final k in _keys) {
        _prefs[k] = true;
      }
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _load(String uid) async {
    _loading = true;
    notifyListeners();
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final raw =
            (doc.data()?['notifPrefs'] as Map<String, dynamic>?) ?? {};
        for (final k in _keys) {
          if (raw.containsKey(k)) {
            _prefs[k] = (raw[k] as bool?) ?? true;
          }
        }
      }
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }
}
