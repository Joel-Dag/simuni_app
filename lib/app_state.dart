// lib/app_state.dart
import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  String name;
  UserProfile({required this.id, required this.name});
}

class AppState extends ChangeNotifier {
  bool _isFirstTimeUser = true;
  bool _isDarkMode = true;
  String _currentFont = "Inter";
  double _fontSize = 14.0;
  
  String _apiKey = "";
  String _aiProvider = "Gemini"; // Gemini, Custom OpenAI endpoint, etc.

  // Notification Flags
  bool txAlerts = true;
  bool budgetAlerts = true;

  // Profiles Matrix Handling
  final List<UserProfile> _profiles = [];
  int _activeProfileIndex = 0;

  bool get isFirstTimeUser => _isFirstTimeUser;
  bool get isDarkMode => _isDarkMode;
  String get currentFont => _currentFont;
  double get fontSize => _fontSize;
  String get apiKey => _apiKey;
  String get aiProvider => _aiProvider;
  List<UserProfile> get profiles => _profiles;
  UserProfile get activeProfile => _profiles.isNotEmpty ? _profiles[_activeProfileIndex] : UserProfile(id: "0", name: "Guest");

  void completeOnboarding() {
    _isFirstTimeUser = false;
    notifyListeners();
  }

  void updateApiKey(String key, String provider) {
    _apiKey = key;
    _aiProvider = provider;
    notifyListeners();
  }

  void toggleTheme(bool dark) {
    _isDarkMode = dark;
    notifyListeners();
  }

  void updateTypography(String font, double size) {
    _currentFont = font;
    _fontSize = size;
    notifyListeners();
  }

  void toggleNotificationSettings(String type, bool value) {
    if (type == "tx") txAlerts = value;
    if (type == "budget") budgetAlerts = value;
    notifyListeners();
  }

  void createNewProfile(String name) {
    final newProf = UserProfile(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name);
    _profiles.add(newProf);
    _activeProfileIndex = _profiles.length - 1;
    notifyListeners();
  }

  void switchProfile(int index) {
    if (index >= 0 && index < _profiles.length) {
      _activeProfileIndex = index;
      notifyListeners();
    }
  }
}