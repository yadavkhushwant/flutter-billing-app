import 'package:billing_application/controller/google_drive_backup_controller.dart';
import 'package:billing_application/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DatabaseBackupCard extends StatelessWidget {
  DatabaseBackupCard({super.key});

  final BackupController backupController = Get.put(BackupController());

  /// Helper: Converts bytes to a human-readable string.
  String formatBytes(int bytes) {
    const kb = 1024;
    const mb = kb * 1024;
    if (bytes >= mb) {
      return "${(bytes / mb).toStringAsFixed(2)} MB";
    } else if (bytes >= kb) {
      return "${(bytes / kb).toStringAsFixed(2)} KB";
    } else {
      return "$bytes B";
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      title: const Text(
        "Database Backup",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backup Email Section
            const Text("Backup Account",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

         /*   Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      backupController.backupEmail.value.isEmpty
                          ? 'Not Authenticated'
                          : backupController.backupEmail.value,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    )),
                const SizedBox(height: 8),
                Center(
                  child: Obx(() {
                    if (backupController.backupEmail.value.isEmpty) {
                      return Button(
                        type: ButtonType.primary,
                        onPressed: () => backupController.login(),
                        // Only logs in
                        text: "Login",
                      );
                    } else {
                      return Button(
                        type: ButtonType.secondary,
                        onPressed: () => backupController.clearCredentials(),
                        text: "Logout",
                      );
                    }
                  }),
                ),
              ],
            ),*/
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() {
                  if (backupController.isLoadingEmail.value) {
                    return Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        const Text("Loading Email...", style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    );
                  }
                  return Text(
                    backupController.backupEmail.value.isEmpty
                        ? 'Not Authenticated'
                        : backupController.backupEmail.value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  );
                }),

                const SizedBox(height: 8),

                Center(
                  child: Obx(() {
                    if (backupController.isLoadingEmail.value) {
                      return const SizedBox(); // Hide buttons while loading
                    }
                    if (backupController.backupEmail.value.isEmpty) {
                      return Button(
                        type: ButtonType.primary,
                        onPressed: () => backupController.login(),
                        text: "Login",
                      );
                    } else {
                      return Button(
                        type: ButtonType.secondary,
                        onPressed: () => backupController.clearCredentials(),
                        text: "Logout",
                      );
                    }
                  }),
                ),
              ],
            ),

            const Divider(height: 20, thickness: 1),
            // Last Backup Section
            const Text("Last Backup",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Obx(() => Text(
                  backupController.lastBackup.value.isEmpty
                      ? 'Never'
                      : backupController.lastBackup.value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                )),
            const SizedBox(height: 16),
            // Progress Indicator (if backing up)
            Obx(() {
              if (!backupController.isBackingUp.value) {
                return const SizedBox.shrink();
              }
              final progressPercent =
                  (backupController.uploadProgress.value * 100)
                      .toStringAsFixed(2);
              final uploaded =
                  formatBytes(backupController.uploadedBytes.value);
              final total = formatBytes(backupController.totalBytes.value);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: backupController.uploadProgress.value,
                    minHeight: 6,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Uploaded: $uploaded / $total ($progressPercent%)",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => !backupController.isBackingUp.value
                    ? Button(
                        onPressed: () => backupController.performBackup(),
                        text: "Backup Now",
                        type: ButtonType.primary,
                      )
                    : const SizedBox.shrink()),

                const SizedBox(width: 16),

                Obx(() => backupController.isBackingUp.value
                    ? Button(
                        onPressed: () {
                          backupController.isCancelled.value = true;
                        },
                        text: "Cancel Backup",
                        type: ButtonType.secondary,
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Button(
          type: ButtonType.secondary,
          onPressed: () => Get.back(),
          text: "Close",
        ),
      ],
    );
  }
}
