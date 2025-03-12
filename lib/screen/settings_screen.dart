import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:billing_application/widget/main_scaffold.dart';
import 'package:billing_application/widget/button.dart';
import 'package:billing_application/widget/input_decoration.dart';
import 'package:billing_application/controller/settings_controller.dart';
import 'package:billing_application/controller/theme_controller.dart';

import '../widget/database_backup_card.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final SettingsController controller = Get.put(SettingsController());
  final ThemeController themeController = Get.find<ThemeController>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    controller.inflateValuesInInput();
    return MainScaffold(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Business Name Field
                        TextFormField(
                          controller: controller.businessNameController,
                          decoration: getInputDecoration("Business Name"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter business name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Email Field
                        TextFormField(
                          controller: controller.emailController,
                          decoration: getInputDecoration("Email"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Contact Number Field
                        TextFormField(
                          controller: controller.contactController,
                          decoration: getInputDecoration("Contact Number"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter contact number";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Address Field
                        TextFormField(
                          controller: controller.addressController,
                          decoration: getInputDecoration("Address"),
                        ),
                        const SizedBox(height: 16),
                        // Logo Field: Show current logo (if any) and allow picking a new image.
                        Row(
                          children: [
                            Obx(() {
                              return controller.logoPath.value.isNotEmpty
                                  ? Image.file(
                                File(controller.logoPath.value),
                                fit: BoxFit.contain,
                                width: 150,
                                height: 100,
                              )
                                  : Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 50),
                              );
                            }),
                            const SizedBox(width: 16),
                            Button(
                              type: ButtonType.secondary,
                              onPressed: () => controller.pickLogo(),
                              text: "Select Logo",
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Theme Selection
                        const Text("Theme Settings",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: [
                            _colorOption(Colors.blue),
                            _colorOption(Colors.red),
                            _colorOption(Colors.green),
                            _colorOption(Colors.purple),
                            _colorOption(Colors.orange),
                            _colorOption(Colors.indigo),
                            _colorOption(Colors.blueGrey),
                            _colorOption(Colors.yellow),
                            _colorOption(Colors.deepOrange),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Dark Mode Toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Dark Mode",
                                style: TextStyle(fontSize: 16)),
                            Switch(
                              value: themeController.isDarkMode.value,
                              onChanged: (value) {
                                themeController.toggleDarkMode(value);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Save Settings Button
                        Center(
                          child: Button(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                controller.saveSettings();
                              }
                            },
                            text: "Save Settings",
                          ),
                        ),
                        // Backup Card Section
                        DatabaseBackupCard(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _colorOption(Color color) {
    return GestureDetector(
      onTap: () {
        themeController.setThemeColor(color);
      },
      child: Obx(() => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: themeController.selectedColor.value == color
              ? Border.all(color: Colors.black, width: 2)
              : null,
        ),
      )),
    );
  }
}
