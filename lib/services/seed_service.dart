// ─────────────────────────────────────────────────────────────
// SeedService — loads assets/seed_data.json on app start and:
//
//   CREATE  — writes items that don't exist in Firestore yet.
//   PATCH   — updates imageUrl on existing docs where it is
//             empty but the seed JSON now has a value.
//             (lets you add images later without re-seeding)
//
// Everything is non-fatal: errors are logged and swallowed so
// the app always starts even if Firestore is unreachable.
// ─────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class SeedService {
  SeedService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Call once in main() after Firebase.initializeApp().
  static Future<void> run() async {
    try {
      final raw =
          await rootBundle.loadString('assets/seed_data.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;

      await _seedCollection(
        items: json['products'] as List<dynamic>? ?? [],
        collection: 'products',
      );

      // Add more collections here as you extend seed_data.json:
      // await _seedCollection(items: json['categories'] ?? [], collection: 'categories');
    } catch (e, st) {
      debugPrint('[SeedService] Non-fatal error: $e\n$st');
    }
  }

  // ── Internal ──────────────────────────────────────────────────

  static Future<void> _seedCollection({
    required List<dynamic> items,
    required String collection,
  }) async {
    if (items.isEmpty) return;

    final seeds = items.cast<Map<String, dynamic>>();

    // 1. Fetch all existing docs in one round-trip.
    final existingSnap = await _db.collection(collection).get();
    final existingById = {
      for (final doc in existingSnap.docs) doc.id: doc.data(),
    };

    // 2. Categorise each seed item.
    final toCreate = <Map<String, dynamic>>[];   // new docs
    final toPatch  = <Map<String, dynamic>>[];   // imageUrl patch only

    for (final item in seeds) {
      final id = (item['id'] as String?) ?? '';
      if (id.isEmpty) continue;

      if (!existingById.containsKey(id)) {
        toCreate.add(item);
      } else {
        // Doc already exists — patch imageUrl if seed has one and it
        // differs from what's live (handles empty OR changed/broken URLs).
        final seedUrl  = (item['imageUrl'] as String?) ?? '';
        final liveUrl  = (existingById[id]!['imageUrl'] as String?) ?? '';
        if (seedUrl.isNotEmpty && seedUrl != liveUrl) {
          toPatch.add(item);
        }
      }
    }

    if (toCreate.isEmpty && toPatch.isEmpty) {
      debugPrint('[SeedService] $collection — nothing to do '
          '(${existingById.length} docs already up to date).');
      return;
    }

    // 3. Batch-write in chunks of 500 (Firestore hard limit).
    //    Each entry is ('create'|'patch', item).
    final ops = [
      for (final i in toCreate) ('create', i),
      for (final i in toPatch)  ('patch',  i),
    ];

    const chunkSize = 500;
    for (var offset = 0; offset < ops.length; offset += chunkSize) {
      final chunk = ops.skip(offset).take(chunkSize);
      final batch = _db.batch();

      for (final (op, item) in chunk) {
        final id  = item['id'] as String;
        final ref = _db.collection(collection).doc(id);

        if (op == 'create') {
          batch.set(ref, _toFirestoreData(item));
        } else {
          // Patch: only overwrite the imageUrl field.
          batch.update(ref, {'imageUrl': item['imageUrl'] as String});
        }
      }

      await batch.commit();
    }

    if (toCreate.isNotEmpty) {
      debugPrint('[SeedService] $collection '
          '— created ${toCreate.length} new doc(s).');
    }
    if (toPatch.isNotEmpty) {
      debugPrint('[SeedService] $collection '
          '— patched imageUrl on ${toPatch.length} doc(s).');
    }
  }

  /// Converts a JSON map into a Firestore-ready map.
  ///
  /// • Removes `id` — used as document ID, not stored as a field.
  /// • Converts `tint` hex strings ("0xFF1A1816") → int values so
  ///   Firestore stores them as numbers (matching _docToProduct).
  static Map<String, dynamic> _toFirestoreData(
      Map<String, dynamic> raw) {
    final data = Map<String, dynamic>.from(raw)..remove('id');

    if (data['tint'] is List) {
      data['tint'] = (data['tint'] as List).map((t) {
        if (t is String) return int.parse(t);
        if (t is int) return t;
        return 0xFF1A1816;
      }).toList();
    }

    return data;
  }
}
