import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_data.dart';

/// Persistencia local (localStorage en web, SharedPreferences en móvil).
/// Usa la misma clave que la versión HTML.
class StorageService {
  static const key = 'sebasgova_edicion_db_v1';

  Future<AppData?> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return AppData.fromJson(Map<String, dynamic>.from(decoded));
    } catch (e) {
      debugPrint('No se pudo leer el almacenamiento: $e');
      return null;
    }
  }

  Future<void> write(AppData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(data.toJson()));
    } catch (e) {
      debugPrint('No se pudo guardar: $e');
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
