import 'package:billing_application/utils/toasts.dart';
import 'package:billing_application/widget/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      child: Align(
        alignment: Alignment.topCenter, // Moves the card to the top
        child: Container(
          width: double.infinity,
          height: 350,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20), // Top margin added
          constraints: const BoxConstraints(maxWidth: 600), // Limits width on large screens
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Aligns content to the left
            children: [
              // App Name
              Text(
                "Invoicely",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),

              // Version Info
              Text(
                "Version 1.0.0  |  Release Date: 10-03-2025",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),

              const Text(
                "Developed by:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              // Developer Info
              const Text(
                "Khushwant Pratap Yadav",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Text(
                "+91 8858013899",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "yadavkhushwant777@gmail.com",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              // Social Links Row (Desktop Layout)
              Row(
                mainAxisAlignment: MainAxisAlignment.start, // Aligns left
                children: [
                  _socialLink(Icons.code, "GitHub", "https://github.com/yadavkhushwant/"),
                  const SizedBox(width: 20),
                  _socialLink(Icons.person, "LinkedIn", "https://www.linkedin.com/in/yadavkhushwant/"),
                ],
              ),
              const SizedBox(height: 20),

              // Footer (Copyright)
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                "© 2025 Invoicely. All rights reserved.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _socialLink(IconData icon, String text, String url) {
    return GestureDetector(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint(e.toString());
          errorToast("Could not open link: $e");
        }
      },
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
