import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ArchivedRecoveryProgram {
  final String programId;
  final DateTime archivedAt;
  final int completedDays;
  final int totalDays;

  const ArchivedRecoveryProgram({
    required this.programId,
    required this.archivedAt,
    required this.completedDays,
    required this.totalDays,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'programId': programId,
        'archivedAt': archivedAt.toUtc().toIso8601String(),
        'completedDays': completedDays,
        'totalDays': totalDays,
      };

  factory ArchivedRecoveryProgram.fromJson(Map<String, dynamic> json) {
    return ArchivedRecoveryProgram(
      programId: json['programId'] as String? ?? '',
      archivedAt: DateTime.tryParse(json['archivedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      completedDays: json['completedDays'] as int? ?? 0,
      totalDays: json['totalDays'] as int? ?? 0,
    );
  }
}

class ActiveRecoveryProgramState {
  final String? activeProgramId;
  final DateTime? startedAt;
  final List<ArchivedRecoveryProgram> pastPrograms;

  const ActiveRecoveryProgramState({
    required this.activeProgramId,
    required this.startedAt,
    required this.pastPrograms,
  });

  bool get hasActiveProgram =>
      activeProgramId != null && activeProgramId!.trim().isNotEmpty;
}

class ActiveRecoveryProgramRepository {
  static const String _activeProgramKey =
      'active_recovery_program_id_v1';
  static const String _startedAtKey =
      'active_recovery_program_started_at_v1';
  static const String _pastProgramsKey =
      'archived_recovery_programs_v1';

  Future<ActiveRecoveryProgramState> getState() async {
    final prefs = await SharedPreferences.getInstance();
    final rawId = prefs.getString(_activeProgramKey)?.trim();
    final startedAt = DateTime.tryParse(
      prefs.getString(_startedAtKey) ?? '',
    );
    final rawPast = prefs.getStringList(_pastProgramsKey) ?? <String>[];
    final past = <ArchivedRecoveryProgram>[];

    for (final raw in rawPast) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          final item = ArchivedRecoveryProgram.fromJson(decoded);
          if (item.programId.isNotEmpty) {
            past.add(item);
          }
        }
      } catch (_) {
        // Ignore malformed local history instead of blocking recovery access.
      }
    }

    return ActiveRecoveryProgramState(
      activeProgramId:
          rawId == null || rawId.isEmpty ? null : rawId,
      startedAt: startedAt,
      pastPrograms: past,
    );
  }

  Future<void> startProgram({
    required String programId,
    String? previousProgramId,
    int previousCompletedDays = 0,
    int previousTotalDays = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanProgramId = programId.trim();
    if (cleanProgramId.isEmpty) {
      throw ArgumentError.value(programId, 'programId');
    }

    if (previousProgramId != null &&
        previousProgramId.trim().isNotEmpty &&
        previousProgramId != cleanProgramId) {
      final state = await getState();
      final archive = ArchivedRecoveryProgram(
        programId: previousProgramId,
        archivedAt: DateTime.now().toUtc(),
        completedDays: previousCompletedDays,
        totalDays: previousTotalDays,
      );
      final updated = <ArchivedRecoveryProgram>[
        archive,
        ...state.pastPrograms.where(
          (item) => item.programId != previousProgramId,
        ),
      ].take(12).toList();
      await prefs.setStringList(
        _pastProgramsKey,
        updated.map((item) => jsonEncode(item.toJson())).toList(),
      );
    }

    await prefs.setString(_activeProgramKey, cleanProgramId);
    await prefs.setString(
      _startedAtKey,
      DateTime.now().toUtc().toIso8601String(),
    );
  }
}
