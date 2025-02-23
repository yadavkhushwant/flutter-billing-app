import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:billing_application/controller/uom_controller.dart';

class EditUomDialog extends StatelessWidget {
  final Map<String, dynamic> uom;
  const EditUomDialog({super.key, required this.uom});

  @override
  Widget build(BuildContext context) {
    final UomController uomController = Get.find<UomController>();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController nameController =
    TextEditingController(text: uom['name']);

    return AlertDialog(
      title: const Text("Edit UOM"),
      content: SingleChildScrollView(
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
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final updatedUom = {
                'name': nameController.text,
              };
              uomController.updateUom(uom['id'], updatedUom);
              Get.back();
            }
          },
          child: const Text("Save"),
        )
      ],
    );
  }
}
