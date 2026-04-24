import 'package:flutter/foundation.dart';

class WishlistManager extends ChangeNotifier {
  final Set<String> _ids = {};

  int get count => _ids.length;
  List<String> get ids => _ids.toList();
  bool contains(String id) => _ids.contains(id);

  void seed() {
    _ids..clear()..addAll(['p_002', 'p_006', 'p_007']);
  }

  void toggle(String id) {
    _ids.contains(id) ? _ids.remove(id) : _ids.add(id);
    notifyListeners();
  }
}
