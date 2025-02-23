import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardCountCard extends StatelessWidget {
  final String title;
  final String count;
  final String complaintType;

  DashboardCountCard(
      {super.key,
      required this.title,
      required this.count,
      required this.complaintType});

  final colors = Theme.of(Get.context!).colorScheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 140,
        child: InkWell(
          onTap: () => Get.toNamed('/complaint-list', arguments: complaintType),
          splashColor: colors.primary.withOpacity(0.5),
          child: Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: colors.primary, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      count,
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ])),
        ),
      ),
    );
  }
}
