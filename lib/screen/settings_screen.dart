import 'dart:io';
import 'package:billing_application/widget/button.dart';
import 'package:billing_application/widget/input_decoration.dart';
import 'package:billing_application/widget/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:billing_application/controller/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final SettingsController controller = Get.put(SettingsController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
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
                                fit: BoxFit.cover,
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
                  // Save Button
                  Center(
                    child: Button(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          controller.saveSettings();
                        }
                      },
                      text: "Save Settings",
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
