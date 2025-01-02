import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorDialog({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRetry();
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }

  static Future<void> show(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        message: message,
        onRetry: onRetry,
      ),
    );
  }
}
