import 'dart:io';
import 'package:billing_application/data/db_crud.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class SettingsController extends GetxController {
  var isLoading = false.obs;
  final SettingsRepository _settingsRepo = SettingsRepository();

  // Form controllers.
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Logo file path.
  var logoPath = ''.obs;

  var settingsData = {
    'businessName': '',
    'email': '',
    'contact': '',
    'address': '',
  }.obs;

  Future<void> fetchSettings() async {
    try {
      isLoading(true);
      var data = await _settingsRepo.getSettings();
      if (data != null) {
        logoPath.value = data['logo'] ?? '';
        settingsData['businessName'] = data['business_name'] ?? 'Invoicely';
        settingsData['email'] = data['email'] ?? '';
        settingsData['contact'] = data['contact_number'] ?? '';
        settingsData['address'] = data['address'] ?? '';

        settingsData.refresh();
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> inflateValuesInInput() async {
    try {
      isLoading(true);
      var data = await _settingsRepo.getSettings();
      if (data != null) {
        businessNameController.text = data['business_name'] ?? '';
        emailController.text = data['email'] ?? '';
        contactController.text = data['contact_number'] ?? '';
        addressController.text = data['address'] ?? '';
        logoPath.value = data['logo'] ?? '';
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> saveSettings() async {
    Map<String, dynamic> newSettings = {
      'business_name': businessNameController.text,
      'email': emailController.text,
      'contact_number': contactController.text,
      'address': addressController.text,
      'logo': logoPath.value,
    };
    await _settingsRepo.saveSettings(newSettings);
    Get.snackbar("Success", "Settings updated",
        snackPosition: SnackPosition.BOTTOM);
    fetchSettings();
  }

  /// Picks an image from the gallery, copies it to the application's directory
  /// with a fixed file name ("logo.extension"), and updates the logoPath.
  Future<void> pickLogo() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Get the application's document directory.
      final Directory appDir = await getApplicationDocumentsDirectory();
      // Extract the extension from the selected image.
      final String ext = p.extension(image.path);
      // Define the new file path (always "logo" with the original extension).
      final String newPath = p.join(appDir.path, 'logo$ext');
      // Copy the file to the new location.
      await File(image.path).copy(newPath);
      // Update the logoPath with the new file location.
      logoPath.value = newPath;
    }
  }
}
