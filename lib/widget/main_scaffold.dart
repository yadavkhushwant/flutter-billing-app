import 'package:billing_application/utils/ui_utils.dart';
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
