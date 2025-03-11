import 'package:billing_application/utils/form_validator.dart';
import 'package:billing_application/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:billing_application/controller/customer_controller.dart';

class CreateCustomerDialog extends StatelessWidget {
  const CreateCustomerDialog({super.key});

  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static final TextEditingController nameController = TextEditingController();
  static final TextEditingController localityController = TextEditingController();
  static final TextEditingController cityController = TextEditingController();
  static final TextEditingController stateController = TextEditingController();
  static final TextEditingController pinController = TextEditingController();
  static final TextEditingController phoneController = TextEditingController();
  static final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final CustomerController customerController = Get.find<CustomerController>();

    return AlertDialog(
      title: const Text("Add Customer"),
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
                    validator: (value) =>validateEmpty(value, "Name")
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
          onPressed: () {
            Get.back(); // Close the dialog.
          },
          text: "Cancel",
        ),
        Button(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              final newCustomer = {
                'name': nameController.text,
                'locality': localityController.text,
                'city': cityController.text,
                'state': stateController.text,
                'pin': pinController.text,
                'phone': phoneController.text,
                'email': emailController.text,
              };

              var customer = await customerController.addCustomer(newCustomer);
              if (customer.isEmpty) return;

              // Clear the fields for next time.
              nameController.clear();
              localityController.clear();
              cityController.clear();
              stateController.clear();
              pinController.clear();
              phoneController.clear();
              emailController.clear();

              Get.back(result: customer);
            }
          },
          text: "Save",
        )
      ],
    );
  }
}
