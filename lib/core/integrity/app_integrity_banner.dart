import 'package:flutter/material.dart';

import 'app_integrity_controller.dart';
import 'app_integrity_status.dart';

class AppIntegrityBanner extends StatelessWidget {
  final Widget child;

  const AppIntegrityBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppIntegrityStatus>(
      valueListenable: AppIntegrityController.instance.status,
      child: child,
      builder: (context, status, content) {
        if (status.state == AppIntegrityState.checking ||
            status.isTrusted) {
          return content ?? const SizedBox.shrink();
        }

        final altered = status.detectedAlteration;
        final title = altered
            ? 'App alteration detected'
            : 'App integrity not verified';

        return Column(
          children: [
            Material(
              color: Theme.of(context).colorScheme.errorContainer,
              child: SafeArea(
                bottom: false,
                child: InkWell(
                  onTap: () => _showDetails(
                    context,
                    title: title,
                    status: status,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.gpp_bad_outlined),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$title — premium features are disabled.',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Icon(Icons.info_outline, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: content ?? const SizedBox.shrink()),
          ],
        );
      },
    );
  }

  Future<void> _showDetails(
    BuildContext context, {
    required String title,
    required AppIntegrityStatus status,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(
            '${status.message}\n\n'
            'Premium and AI access remain disabled. '
            'Rescue and core recovery tools stay available. Install the '
            'official Breakout Addiction release to restore paid access.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
