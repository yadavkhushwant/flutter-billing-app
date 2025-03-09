import 'package:billing_application/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:billing_application/controller/product_controller.dart';
import 'package:billing_application/controller/uom_controller.dart';

class CreateProductDialog extends StatelessWidget {
  const CreateProductDialog({super.key});

  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static final TextEditingController nameController = TextEditingController();
  static final TextEditingController rateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find<ProductController>();
    final UomController uomController = Get.find<UomController>();
    // Use a reactive variable to hold the selected UOM ID.
    final Rxn<int> selectedUomId = Rxn<int>();

    return AlertDialog(
      title: const Text("Add Product"),
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
                // Product Name
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Product Name"),
                  validator: (value) => (value == null || value.isEmpty)
                      ? "Please enter product name"
                      : null,
                ),
                const SizedBox(height: 12),
                // Dropdown for UOM selection.
                Obx(() {
                  if (uomController.uoms.isEmpty) {
                    return const Text("No UOM available");
                  }
                  return DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "Select UOM"),
                    value: selectedUomId.value,
                    items: uomController.uoms.map<DropdownMenuItem<int>>((uom) {
                      return DropdownMenuItem<int>(
                        value: uom['id'] as int,
                        child: Text(uom['name'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedUomId.value = value;
                    },
                    validator: (value) =>
                    value == null ? "Please select a UOM" : null,
                  );
                }),
                const SizedBox(height: 12),
                // Rate field
                TextFormField(
                  controller: rateController,
                  decoration: const InputDecoration(labelText: "Rate"),
                  keyboardType: TextInputType.number,
                  validator: (value) => (value == null || value.isEmpty)
                      ? "Please enter rate"
                      : null,
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
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final newProduct = {
                'name': nameController.text,
                'uom_id': selectedUomId.value,
                'rate': double.tryParse(rateController.text) ?? 0.0,
              };
              final savedProduct = await productController.addProduct(newProduct);
              nameController.clear();
              rateController.clear();
              Get.back(result: savedProduct);
            }
          },
          text: "Save",
        ),
      ],
    );
  }
}
