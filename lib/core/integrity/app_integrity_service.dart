import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_integrity_status.dart';

class AppIntegrityService {
  static const MethodChannel _channel = MethodChannel(
    'com.slimnation.breakoutaddiction/integrity',
  );

  static const String _expectedPackage = String.fromEnvironment(
    'BREAKOUT_EXPECTED_PACKAGE',
    defaultValue: 'com.slimnation.breakoutaddiction',
  );

  static const String _allowedSigningSha256 = String.fromEnvironment(
    'BREAKOUT_ALLOWED_SIGNING_SHA256',
    defaultValue: '',
  );

  Future<AppIntegrityStatus> verify() async {
    if (!kReleaseMode) {
      return const AppIntegrityStatus(
        state: AppIntegrityState.trusted,
        message: 'Development build integrity bypass.',
      );
    }

    final allowed = _allowedSigningSha256
        .split(',')
        .map(_normalizeFingerprint)
        .where((value) => value.isNotEmpty)
        .toSet();

    if (allowed.isEmpty) {
      return const AppIntegrityStatus(
        state: AppIntegrityState.configurationError,
        message:
            'This build is missing its trusted signing-certificate configuration.',
      );
    }

    try {
      final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getIntegrityInfo',
      );

      if (raw == null) {
        return const AppIntegrityStatus(
          state: AppIntegrityState.unavailable,
          message: 'Android did not return app-integrity information.',
        );
      }

      final actualPackage = raw['packageName']?.toString();
      final debuggable = raw['debuggable'] == true;
      final rawSignatures = raw['signingSha256'];

      final signatures = <String>[];
      if (rawSignatures is List) {
        for (final value in rawSignatures) {
          final normalized = _normalizeFingerprint(value.toString());
          if (normalized.isNotEmpty) {
            signatures.add(normalized);
          }
        }
      }

      if (actualPackage != _expectedPackage) {
        return AppIntegrityStatus(
          state: AppIntegrityState.altered,
          message:
              'The installed package identity does not match the official Breakout Addiction build.',
          actualPackage: actualPackage,
          signingFingerprints: signatures,
          debuggable: debuggable,
        );
      }

      if (debuggable) {
        return AppIntegrityStatus(
          state: AppIntegrityState.altered,
          message: 'The installed release was changed to allow debugging.',
          actualPackage: actualPackage,
          signingFingerprints: signatures,
          debuggable: true,
        );
      }

      if (signatures.isEmpty ||
          signatures.every((signature) => !allowed.contains(signature))) {
        return AppIntegrityStatus(
          state: AppIntegrityState.altered,
          message:
              'The installed signing certificate does not match an official Breakout Addiction certificate.',
          actualPackage: actualPackage,
          signingFingerprints: signatures,
          debuggable: debuggable,
        );
      }

      return AppIntegrityStatus(
        state: AppIntegrityState.trusted,
        message: 'Official package identity and signing certificate verified.',
        actualPackage: actualPackage,
        signingFingerprints: signatures,
      );
    } on PlatformException {
      return const AppIntegrityStatus(
        state: AppIntegrityState.unavailable,
        message:
            'Breakout Addiction could not verify this installation on the device.',
      );
    } catch (_) {
      return const AppIntegrityStatus(
        state: AppIntegrityState.unavailable,
        message: 'Breakout Addiction could not complete its integrity check.',
      );
    }
  }

  String _normalizeFingerprint(String value) {
    return value
        .replaceAll(RegExp(r'[^A-Fa-f0-9]'), '')
        .toUpperCase();
  }
}
