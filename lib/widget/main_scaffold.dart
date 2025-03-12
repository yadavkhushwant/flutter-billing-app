import 'package:billing_application/data/database_helper.dart';
import 'package:billing_application/drive_backup_restore/another.dart';
import 'package:billing_application/drive_backup_restore/google_drive_backup.dart';
import 'package:billing_application/drive_backup_restore/google_drive_service.dart';
import 'package:billing_application/utils/ui_utils.dart';
import 'package:billing_application/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'navigation_menu.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool desktop = isDesktop(context);
    final NavigationController navController = Get.find<NavigationController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text(
          'Invoicely',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Button(
            type: ButtonType.secondary,
            text: 'Backup',
            onPressed: () async {
              final db = await DatabaseHelper.instance.database;
              final dbPath = db.path;
              print(dbPath);
              //uploadDatabaseToDrive();
            },
          ),

        ],
        leading: desktop
            ? Obx(() => IconButton(
          icon: Icon(
            navController.isSideNavVisible.value
                ? Icons.menu_open
                : Icons.menu,
            color: theme.colorScheme.onPrimary,
          ),
          onPressed: navController.toggleSideNav,
        ))
            : null,
      ),
      drawer: desktop ? null : const Drawer(child: SideNavigation()),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (desktop)
            Obx(() => navController.isSideNavVisible.value
                ? SizedBox(
              width: 250,
              child: const SideNavigation(),
            )
                : const SizedBox.shrink()),
          Expanded(child: child),
        ],
      ),
    );
  }
}
