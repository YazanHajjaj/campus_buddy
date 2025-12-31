import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineResourceService {
  static const _key = 'offline_resources';

  Future<List<String>> _getIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<bool> isOffline(String resourceId) async {
    final ids = await _getIds();
    return ids.contains(resourceId);
  }

  Future<void> saveOffline(String resourceId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await _getIds();

    if (!ids.contains(resourceId)) {
      ids.add(resourceId);
      await prefs.setStringList(_key, ids);
    }
  }

  Future<void> removeOffline(String resourceId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await _getIds();
    ids.remove(resourceId);
    await prefs.setStringList(_key, ids);
  }

  Future<List<String>> getAllOffline() async {
    return _getIds();
  }
}