import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeBoxName = 'theme_preferences';
  static const String _themeModeKey = 'theme_mode';
  
  Box? _themeBox;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isTestMode = false;
  
  ThemeMode get themeMode => _themeMode;
  
  ThemeProvider() {
    // Don't initialize in constructor - let the app or test set it up
  }
  
  // Method for tests to set a mock box
  void setTestBox(Box mockBox) {
    _isTestMode = true;
    _themeBox = mockBox;
    final savedThemeMode = _themeBox?.get(_themeModeKey, defaultValue: 'system') ?? 'system';
    
    switch (savedThemeMode) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
  }
  
  // Initialize for production use
  Future<void> initialize() async {
    if (!_isTestMode) {
      await _initTheme();
    }
  }
  
  Future<void> _initTheme() async {
    _themeBox = await Hive.openBox(_themeBoxName);
    final savedThemeMode = _themeBox?.get(_themeModeKey, defaultValue: 'system') ?? 'system';
    
    switch (savedThemeMode) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    
    await _themeBox?.put(_themeModeKey, modeString);
    notifyListeners();
  }
  
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      // If system theme, switch to light
      setThemeMode(ThemeMode.light);
    }
  }
}