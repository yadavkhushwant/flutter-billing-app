import 'package:billing_application/widget/navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  Get.put(NavigationController());
  sqfliteFfiInit();

  // Optionally, override the default database factory with the FFI one:
  // (this makes all sqflite calls use FFI)
  databaseFactory = databaseFactoryFfi;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Good Invoice',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lime),
        useMaterial3: true,
      ),
      initialRoute: '/',
      getPages: routes,
    );
  }
}
