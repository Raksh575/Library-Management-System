import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news.dart'; // Make sure this file exists and has toJson/fromJson
import '../models/question_bank.dart' as qb_model;

class LocalStorageService {
  // ===============================
  // 🔹 SharedPreferences Keys
  // ===============================
  static const String _resourcesKey = "resources";
  static const String _newsKey = "news_list";
  static const String _suggestionsKey = "suggestions";
  static const String _questionBanksKey = "question_banks";
  static const String _usersKey = "users";

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

  // =========================================================
  // 🧩 QUESTION BANKS SECTION
  // =========================================================
  static Future<void> saveQuestionBanks(List<qb_model.QuestionBank> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_questionBanksKey, encoded);
  }

  static Future<List<qb_model.QuestionBank>> loadQuestionBanks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_questionBanksKey);
    if (data == null || data.isEmpty) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => qb_model.QuestionBank.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  // =========================================================
  // 👥 USERS (STUDENTS) SECTION
  // =========================================================
  static Future<List<Map<String, dynamic>>> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null || usersJson.isEmpty) return [];
    final List decoded = jsonDecode(usersJson);
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> saveUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(users);
    await prefs.setString(_usersKey, encoded);
  }
}
