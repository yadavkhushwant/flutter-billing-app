import 'package:billing_application/drive_backup_restore/another.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DatabaseBackupCard extends StatelessWidget {
  DatabaseBackupCard({Key? key}) : super(key: key);

  final BackupController backupController = Get.put(BackupController());

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Backup Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Obx(() => Text("Backup Email: ${backupController.backupEmail.value.isEmpty ? 'Not Authenticated' : backupController.backupEmail.value}")),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => backupController.clearCredentials(),
                child: const Text("Change Email"),
              ),
            ),
            const SizedBox(height: 10),
            Obx(() => Text(
                "Last Backup: ${backupController.lastBackup.value.isEmpty ? 'Never' : backupController.lastBackup.value}")),
            const SizedBox(height: 10),
            Obx(() => backupController.isBackingUp.value
                ? const LinearProgressIndicator()
                : const SizedBox.shrink()),
            const SizedBox(height: 10),
            Center(
              child: Obx(() => ElevatedButton(
                onPressed: backupController.isBackingUp.value
                    ? null
                    : () => backupController.performBackup(),
                child: const Text("Backup Now"),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
