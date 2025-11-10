import 'package:flutter/material.dart';

/// Reusable styled snackbar to match the app design used in MyOrdersScreen.
void showStyledSnackBar(BuildContext context,
    {required String title, required String message, bool success = false}) {
  final accent = success ? Colors.green : Colors.purple;
  final icon = success ? Icons.check_circle : Icons.info;

  final content = Container(
    decoration: BoxDecoration(
      color: Colors.purple.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: accent.withOpacity(0.6), width: 2),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4)),
      ],
    ),
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: accent.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(icon, color: accent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: accent)),
              const SizedBox(height: 4),
              Text(message, style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ),
      ],
    ),
  );

  final snack = SnackBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    content: content,
    duration: const Duration(seconds: 4),
  );

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snack);
}
