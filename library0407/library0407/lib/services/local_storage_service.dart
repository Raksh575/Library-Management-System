import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news.dart'; // Make sure this file exists and has toJson/fromJson

class LocalStorageService {
  // ===============================
  // 🔹 SharedPreferences Keys
  // ===============================
  static const String _resourcesKey = "resources";
  static const String _newsKey = "news_list";
  static const String _suggestionsKey = "suggestions";

  // =========================================================
  // 📘 E-RESOURCES SECTION
  // =========================================================
  static Future<void> saveResources(List<Map<String, String>> resources) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(resources);
    await prefs.setString(_resourcesKey, encoded);
  }

  static Future<List<Map<String, String>>> loadResources() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_resourcesKey);
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, String>.from(e)).toList();
  }

  // =========================================================
  // 📰 NEWS SECTION
  // =========================================================
  // Save a list of News objects
  static Future<void> saveNewsList(List<News> newsList) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(newsList.map((n) => n.toJson()).toList());
    await prefs.setString(_newsKey, encoded);
  }

  // Load list of News objects
  static Future<List<News>> loadNewsList() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_newsKey);
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => News.fromJson(e)).toList();
  }

  // Optional: Clear all news
  static Future<void> clearNews() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_newsKey);
  }

  // =========================================================
  // 💬 SUGGESTIONS SECTION
  // =========================================================
  static Future<void> saveSuggestions(List<String> suggestions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_suggestionsKey, suggestions);
  }

  static Future<List<String>> loadSuggestions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_suggestionsKey) ?? [];
  }

  static Future<void> clearSuggestions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_suggestionsKey);
  }
}
