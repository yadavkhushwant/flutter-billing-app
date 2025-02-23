import 'package:billing_application/controller/customer_controller.dart';
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
              TextFormField(
                controller: localityController,
                decoration: const InputDecoration(labelText: "Locality"),
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
                decoration: const InputDecoration(labelText: "Phone"),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
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
              final updatedCustomer = {
                'name': nameController.text,
                'locality': localityController.text,
                'city': cityController.text,
                'state': stateController.text,
                'pin': pinController.text,
                'phone': phoneController.text,
                'email': emailController.text,
              };

              controller.updateCustomer(customer['id'], updatedCustomer);
              Get.back();
            }
          },
          child: const Text("Save"),
        )
      ],
    );
  }
}
