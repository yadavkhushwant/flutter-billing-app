import 'package:billing_application/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:billing_application/controller/uom_controller.dart';

class EditUomDialog extends StatelessWidget {
  final Map<String, dynamic> uom;
  const EditUomDialog({super.key, required this.uom});

  @override
  Widget build(BuildContext context) {
    final UomController uomController = Get.find<UomController>();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController nameController =
    TextEditingController(text: uom['name']);

    return AlertDialog(
      title: const Text("Edit UOM"),
      content: ConstrainedBox(
        constraints: BoxConstraints(
            minWidth: 560
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name *"),
                  validator: (value) =>
                  (value == null || value.isEmpty) ? "Please enter a name" : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Button(
          type: ButtonType.secondary,
          onPressed: () => Get.back(),
          text: "Cancel",
        ),
        Button(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              final updatedUom = {
                'name': nameController.text,
              };
              uomController.updateUom(uom['id'], updatedUom);
              Get.back();
            }
          },
          text: "Save",
        )
      ],
    );
  }
}
