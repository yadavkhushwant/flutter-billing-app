import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motion_toast/motion_toast.dart';

void successToast(String message, [String? title]){
  MotionToast.success(
    title:  Text(title ?? "Success"),
    description:  Text(message),
    position: MotionToastPosition.top,
  ).show(Get.overlayContext!);
}

void errorToast(String message, [String? title]){
  MotionToast.error(
    title:  Text(title ?? "Error"),
    description:  Text(message),
    position: MotionToastPosition.top,
  ).show(Get.overlayContext!);
}

void warningToast(String message, [String? title]){
  MotionToast.warning(
    title:  Text(title ?? "Warning"),
    description:  Text(message),
    position: MotionToastPosition.top,
  ).show(Get.overlayContext!);
}

void infoToast(String message, [String? title]){
  MotionToast.info(
    title:  Text(title ?? "Info"),
    description:  Text(message),
    position: MotionToastPosition.top,
  ).show(Get.overlayContext!);
}