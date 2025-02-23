import 'package:flutter/material.dart';
import 'package:get/get.dart';

GetPage createRoute({required String name, required Widget page}) {
  return GetPage(
    name: name,
    page: () => page,
    transition: Transition.fadeIn,
  );
}
