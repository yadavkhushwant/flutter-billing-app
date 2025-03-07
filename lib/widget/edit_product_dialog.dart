import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:billing_application/controller/product_controller.dart';
import 'package:billing_application/controller/uom_controller.dart';

class EditProductDialog extends StatelessWidget {
  final Map<String, dynamic> product;
  const EditProductDialog({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find<ProductController>();
    final UomController uomController = Get.find<UomController>();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    // Prepopulate text controllers.
    final TextEditingController nameController =
    TextEditingController(text: product['name']);
    final TextEditingController rateController =
    TextEditingController(text: product['rate'].toString());
    // Use a reactive variable for selected UOM; prefill with current uom_id.
    final Rxn<int> selectedUomId = Rxn<int>(product['uom_id'] as int?);

    return AlertDialog(
      title: const Text("Edit Product"),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
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
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final updatedProduct = {
                'name': nameController.text,
                'uom_id': selectedUomId.value,
                'rate': double.tryParse(rateController.text) ?? 0.0,
              };
              productController.updateProduct(product['id'], updatedProduct);
              Get.back();
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
