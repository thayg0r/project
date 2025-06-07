import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PostStorage {
  static Future<List<Map<String, String>>> loadPostagens() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString('postagens');

    if (storedData != null) {
      final List<dynamic> decodedData = json.decode(storedData);
      return decodedData.map((item) => Map<String, String>.from(item)).toList();
    }
    return [];
  }

  static Future<void> savePosts(List<Map<String, String>> postagens) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('postagens', json.encode(postagens));
  }
}
