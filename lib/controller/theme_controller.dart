import 'package:billing_application/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  Rx<MaterialColor> selectedColor = Colors.indigo.obs; // Default theme color
  RxBool isDarkMode = false.obs; // Default system mode

  @override
  void onInit() {
    _loadThemeSettings();
    super.onInit();
  }

  // Load theme settings (color & dark mode) from shared preferences
  Future<void> _loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    int? colorValue = prefs.getInt('themeColor');
    bool? darkModeValue = prefs.getBool('isDarkMode');

    if (colorValue != null) selectedColor.value = MaterialColor(colorValue, _colorSwatch(colorValue));
    if (darkModeValue != null) isDarkMode.value = darkModeValue;
  }

  // Save color to shared preferences and update theme
  Future<void> setThemeColor(MaterialColor color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeColor', color.toInt());
    selectedColor.value = color;
  }

  // Toggle dark/light mode
  Future<void> toggleDarkMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', enabled);
    isDarkMode.value = enabled;
  }

  Map<int, Color> _colorSwatch(int colorValue) {
    return {
      50: Color(colorValue).withValues(alpha: 0.1),
      100: Color(colorValue).withValues(alpha: 0.2),
      200: Color(colorValue).withValues(alpha: 0.3),
      300: Color(colorValue).withValues(alpha: 0.4),
      400: Color(colorValue).withValues(alpha: 0.5),
      500: Color(colorValue),
      600: Color(colorValue).withValues(alpha: 0.7),
      700: Color(colorValue).withValues(alpha: 0.8),
      800: Color(colorValue).withValues(alpha: 0.9),
      900: Color(colorValue).withValues(alpha: 1.0),
    };
  }
}
