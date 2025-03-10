import 'package:billing_application/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:billing_application/controller/payment_controller.dart';

class EditPaymentDialog extends StatelessWidget {
  final Map<String, dynamic> payment;
  const EditPaymentDialog({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final PaymentController paymentController = Get.find<PaymentController>();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController paymentDateController =
    TextEditingController(text: payment['payment_date']);
    final TextEditingController amountController =
    TextEditingController(text: payment['amount']?.toString());
    final TextEditingController paymentReferenceController =
    TextEditingController(text: payment['payment_reference']);
    final TextEditingController notesController =
    TextEditingController(text: payment['notes']);

    return AlertDialog(
      title: const Text("Edit Payment"),
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
                // Payment Date using a Date Picker.
                TextFormField(
                  controller: paymentDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Payment Date (YYYY-MM-DD)",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    DateTime initialDate;
                    try {
                      initialDate = DateFormat('yyyy-MM-dd')
                          .parse(paymentDateController.text);
                    } catch (_) {
                      initialDate = DateTime.now();
                    }
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
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
              final updatedPayment = {
                'payment_date': paymentDateController.text,
                'amount': double.tryParse(amountController.text) ?? 0.0,
                'payment_reference': paymentReferenceController.text,
                'notes': notesController.text,
              };
              paymentController.updatePayment(payment['id'], updatedPayment);
              Get.back();
            }
          },
          text: "Save",
        )
      ],
    );
  }
}
