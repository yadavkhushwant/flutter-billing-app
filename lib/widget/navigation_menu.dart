import 'package:billing_application/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// GetX Controller for handling navigation state.
class NavigationController extends GetxController {
  // Controls the side navigation visibility.
  final isSideNavVisible = true.obs;

  // Tracks the active route.
  final activeRoute = '/home'.obs;

  void toggleSideNav() {
    isSideNavVisible.value = !isSideNavVisible.value;
  }

  void setActiveRoute(String route) {
    activeRoute.value = route;
  }
}

/// Side Navigation widget with professional styling.
class SideNavigation extends StatelessWidget {
  const SideNavigation({super.key});

  /// Helper method that builds a navigation list item.
  Widget buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String routeName,
  }) {
    final NavigationController navController = Get.find<NavigationController>();

    return Obx(() {
      bool isActive = navController.activeRoute.value == routeName;
      return ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.indigo : Colors.grey[700],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.indigo : Colors.grey[700],
          ),
        ),
        tileColor: isActive ? Colors.indigo : Colors.transparent,
        onTap: () {
          // Use the provided context to close the drawer on mobile.
          if (!isDesktop(context)) Navigator.pop(context);
          // Set this route as active.
          navController.setActiveRoute(routeName);
          // Navigate to the route.
          Get.offAllNamed(routeName);
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Background for the navigation items section.
      color: Colors.indigo[50],
      child: ListView(
        children: [
          // DrawerHeader with matching color as the AppBar.
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.indigo[900],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30, color: Colors.indigo),
                ),
                SizedBox(height: 10),
                Text(
                  "Billing App",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Navigation items.
          buildNavItem(context,
              icon: Icons.dashboard, title: "Dashboard", routeName: '/home'),
          buildNavItem(context,
              icon: Icons.receipt_long,
              title: "Create Invoice",
              routeName: '/create-invoice'),

          buildNavItem(context,
              icon: Icons.request_page_outlined,
              title: "Sales Report",
              routeName: '/sales-report'),
          buildNavItem(context,
              icon: Icons.account_box,
              title: "Customers",
              routeName: '/manage-customer'),

          buildNavItem(context,
              icon: Icons.map_rounded, title: "UOM", routeName: '/manage-uom'),

          buildNavItem(context,
              icon: Icons.production_quantity_limits_sharp,
              title: "Products",
              routeName: '/manage-products'),

          buildNavItem(context,
              icon: Icons.settings, title: "Settings", routeName: '/settings'),
          // Add more navigation items here.
        ],
      ),
    );
  }
}
