import 'package:billing_application/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  Rx<Color> selectedColor = Colors.indigo.obs; // Default theme color
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

    if (colorValue != null) selectedColor.value = Color(colorValue);
    if (darkModeValue != null) isDarkMode.value = darkModeValue;
  }

  // Save color to shared preferences and update theme
  Future<void> setThemeColor(Color color) async {
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
}
