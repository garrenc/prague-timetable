import 'package:flutter/material.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final String details;
  final VoidCallback onRetry;
  const ErrorStateWidget({super.key, required this.message, required this.details, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0), child: Text(details, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Zkusit znovu')),
        ],
      ),
    );
  }
}
