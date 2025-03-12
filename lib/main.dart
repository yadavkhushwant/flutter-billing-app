import 'package:billing_application/controller/theme_controller.dart';
import 'package:billing_application/widget/navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  Get.put(NavigationController());
  Get.put(ThemeController()); // Initialize theme controller

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() {
      bool isDark = themeController.isDarkMode.value;
      Color selectedColor = themeController.selectedColor.value;

      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Invoicely',
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: selectedColor,
            brightness: Brightness.light, // Ensure brightness matches
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: selectedColor,
            brightness: Brightness.dark, // Ensure brightness matches
          ),
          useMaterial3: true,
        ),
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        initialRoute: '/',
        getPages: routes,
      );
    });
  }
}
