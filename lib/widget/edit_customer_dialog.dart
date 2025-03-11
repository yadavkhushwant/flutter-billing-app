import 'package:billing_application/controller/customer_controller.dart';
import 'package:billing_application/utils/form_validator.dart';
import 'package:billing_application/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditCustomerDialog extends StatelessWidget {
  final Map<String, dynamic> customer;
  EditCustomerDialog({super.key, required this.customer});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController =
  TextEditingController(text: customer['name']);
  late final TextEditingController localityController =
  TextEditingController(text: customer['locality']);
  late final TextEditingController cityController =
  TextEditingController(text: customer['city']);
  late final TextEditingController stateController =
  TextEditingController(text: customer['state']);
  late final TextEditingController pinController =
  TextEditingController(text: customer['pin']);
  late final TextEditingController phoneController =
  TextEditingController(text: customer['phone']);
  late final TextEditingController emailController =
  TextEditingController(text: customer['email']);

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.find<CustomerController>();

    return AlertDialog(
      title: const Text("Edit Customer"),
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
                  decoration: const InputDecoration(labelText: "Name *"),
                  validator: (value) =>
                  (value == null || value.isEmpty) ? "Please enter a name" : null,
                ),
                TextFormField(
                  controller: localityController,
                  decoration: const InputDecoration(labelText: "Locality *"),
                  validator: (value) =>validateEmpty(value, "Locality")
                ),
                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: "City"),
                ),
                TextFormField(
                  controller: stateController,
                  decoration: const InputDecoration(labelText: "State"),
                ),
                TextFormField(
                  controller: pinController,
                  decoration: const InputDecoration(labelText: "Pin"),
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone *"),
                  validator: (value) =>validateEmpty(value, "Phone")
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
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
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              final updatedCustomer = {
                'name': nameController.text,
                'locality': localityController.text,
                'city': cityController.text,
                'state': stateController.text,
                'pin': pinController.text,
                'phone': phoneController.text,
                'email': emailController.text,
              };

              final isUpdated = await controller.updateCustomer(customer['id'], updatedCustomer);
              if(isUpdated){
                Get.back();
              }
            }
          },
          text: "Save",
        )
      ],
    );
  }
}
