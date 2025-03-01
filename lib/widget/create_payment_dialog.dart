import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:billing_application/controller/payment_controller.dart';

class CreatePaymentDialog extends StatelessWidget {
  const CreatePaymentDialog({super.key});

  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static final TextEditingController paymentDateController =
  TextEditingController();
  static final TextEditingController amountController = TextEditingController();
  static final TextEditingController paymentReferenceController =
  TextEditingController();
  static final TextEditingController notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final PaymentController paymentController = Get.find<PaymentController>();

    return AlertDialog(
      title: const Text("Add Payment"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Customer selection dropdown.
              Obx(() {
                return DropdownButtonFormField<int>(
                  value: paymentController.customers.isNotEmpty
                      ? paymentController.customers.first['id']
                      : null,
                  decoration: const InputDecoration(labelText: "Customer"),
                  items: paymentController.customers.map((customer) {
                    return DropdownMenuItem<int>(
                      value: customer['id'],
                      child: Text(customer['name']),
                    );
                  }).toList(),
                  onChanged: (val) {},
                  validator: (value) =>
                  (value == null) ? "Please select a customer" : null,
                );
              }),
              // Payment Date using a Date Picker.
              TextFormField(
                controller: paymentDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Payment Date",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    paymentDateController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
                validator: (value) => (value == null || value.isEmpty)
                    ? "Please select a payment date"
                    : null,
              ),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty)
                    ? "Please enter an amount"
                    : null,
              ),
              TextFormField(
                controller: paymentReferenceController,
                decoration:
                const InputDecoration(labelText: "Payment Reference"),
              ),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: "Notes"),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // Close the dialog.
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              // Use the first customer for simplicity.
              final customerId = paymentController.customers.first['id'];
              final newPayment = {
                'customer_id': customerId,
                'payment_date': paymentDateController.text,
                'amount': double.tryParse(amountController.text) ?? 0.0,
                'payment_reference': paymentReferenceController.text,
                'notes': notesController.text,
                // Removed 'customer_name' as it's not defined in the table.
              };
              paymentController.addPayment(newPayment);
              // Clear the fields after adding.
              paymentDateController.clear();
              amountController.clear();
              paymentReferenceController.clear();
              notesController.clear();
              Get.back();
            }
          },
          child: const Text("Add"),
        )
      ],
    );
  }
}
