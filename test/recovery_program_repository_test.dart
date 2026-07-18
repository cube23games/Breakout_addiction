import 'package:breakout_addiction/features/educate/data/lesson_repository.dart';
import 'package:breakout_addiction/features/premium_tools/data/recovery_program_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Plus programs provide substantial structured recovery', () {
    final programs = RecoveryProgramRepository.programs;
    final ids = programs.map((program) => program.id).toList();

    expect(programs.length, greaterThanOrEqualTo(7));
    expect(ids.toSet().length, ids.length);
    expect(
      programs.any((program) => program.durationDays == 30),
      isTrue,
    );
    expect(
      programs.any((program) => program.faithSensitive),
      isTrue,
    );
    for (final program in programs) {
      expect(program.hasDailyStructure, isTrue);
    }
  });

  test('Educate Me Plus contains a durable premium library', () {
    final tracks = LessonRepository()
        .getTracks()
        .where((track) => track.premiumOnly)
        .toList();
    final lessons = tracks.expand((track) => track.lessons).toList();

    expect(tracks.length, greaterThanOrEqualTo(9));
    expect(lessons.length, greaterThanOrEqualTo(25));
    expect(
      tracks.any((track) => track.id == 'plus_sleep_night'),
      isTrue,
    );
    expect(
      tracks.any((track) => track.id == 'plus_accountability'),
      isTrue,
    );
    expect(
      tracks.any((track) => track.id == 'plus_faith_recovery'),
      isTrue,
    );
  });
}
