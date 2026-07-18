import 'lesson.dart';

class LessonTrack {
  final String id;
  final String title;
  final String subtitle;
  final List<Lesson> lessons;
  final bool premiumOnly;

  const LessonTrack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.lessons,
    this.premiumOnly = false,
  });
}
