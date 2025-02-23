import 'package:billing_application/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'navigation_menu.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool desktop = isDesktop(context);
    final NavigationController navController = Get.find<NavigationController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[900],
        title: const Text('Billing Software'),
        // For desktop, display a toggle button that reacts to the observable.
        leading: desktop
            ? Obx(() => IconButton(
                  icon: Icon(
                    navController.isSideNavVisible.value
                        ? Icons.menu_open
                        : Icons.menu,
                  ),
                  onPressed: () {
                    navController.toggleSideNav();
                  },
                ))
            : null,
      ),
      // For mobile, use a drawer.
      drawer: desktop ? null : const Drawer(child: SideNavigation()),
      body: Row(
        children: [
          // For desktop, conditionally show the side navigation.
          if (desktop)
            Obx(() => navController.isSideNavVisible.value
                ? SizedBox(
                    width: 250,
                    child: const SideNavigation(),
                  )
                : const SizedBox.shrink()),
          // Main content area.
          Expanded(child: child),
        ],
      ),
    );
  }
}
