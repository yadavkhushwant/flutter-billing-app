import 'package:billing_application/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:billing_application/controller/uom_controller.dart';

class CreateUomDialog extends StatelessWidget {
  const CreateUomDialog({super.key});

  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final UomController uomController = Get.find<UomController>();

    return AlertDialog(
      title: const Text("Add UOM"),
      content: ConstrainedBox(
        constraints: BoxConstraints(
            minWidth: 560
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
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
          onPressed: () {
            Get.back(); // Close the dialog.
          },
          text: "Cancel",
        ),
        Button(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final newUom = {
                'name': nameController.text,
              };
              uomController.addUom(newUom);
              nameController.clear();
              Get.back();
            }
          },
          text: "Save",
        )
      ],
    );
  }
}
