import 'package:flutter/material.dart';

Future<bool> showRecoveryEventDeleteDialog(
  BuildContext context,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          'Delete recovery event?',
        ),
        content: const Text(
          'This removes the saved log from this '
          'device. You can undo immediately after '
          'deleting.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              false,
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              true,
            ),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  return confirmed ?? false;
}
