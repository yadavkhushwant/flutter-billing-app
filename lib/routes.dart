import 'package:billing_application/screen/create_invoice_screen.dart';
import 'package:billing_application/screen/home_screen.dart';
import 'package:billing_application/screen/manage_customer_screen.dart';
import 'package:billing_application/screen/manage_product_screen.dart';
import 'package:billing_application/screen/manage_uom_screen.dart';
import 'package:billing_application/screen/sales_report_screen.dart';
import 'package:billing_application/screen/settings_screen.dart';
import 'package:billing_application/screen/splash_screen.dart';
import 'package:billing_application/utils/route_helper.dart';

final routes = [
  createRoute(name: '/', page: const SplashScreen()),
  createRoute(name: '/home', page: const HomeScreen()),
  createRoute(name: '/create-invoice', page: const CreateInvoiceScreen()),
  createRoute(name: '/sales-report', page: const SalesReportScreen()),
  createRoute(name: '/manage-customer', page: ManageCustomerScreen()),
  createRoute(name: '/manage-uom', page: ManageUomScreen()),
  createRoute(name: '/manage-products', page: const ManageProductScreen()),
  createRoute(name: '/settings', page: SettingsScreen()),

];
