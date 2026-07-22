import 'reason_media_item.dart';

class MyReasonsState {
  const MyReasonsState({
    required this.reasons,
    required this.media,
    this.primaryMediaId,
    this.updatedAt,
  });

  final List<String> reasons;
  final List<ReasonMediaItem> media;
  final String? primaryMediaId;
  final DateTime? updatedAt;

  factory MyReasonsState.empty() {
    return const MyReasonsState(
      reasons: <String>[],
      media: <ReasonMediaItem>[],
    );
  }

  String get primaryReason => reasons.isEmpty ? '' : reasons.first;

  ReasonMediaItem? get primaryMedia {
    if (media.isEmpty) {
      return null;
    }
    if (primaryMediaId != null) {
      for (final item in media) {
        if (item.id == primaryMediaId) {
          return item;
        }
      }
    }
    return media.first;
  }

  MyReasonsState copyWith({
    List<String>? reasons,
    List<ReasonMediaItem>? media,
    String? primaryMediaId,
    bool clearPrimaryMediaId = false,
    DateTime? updatedAt,
  }) {
    return MyReasonsState(
      reasons: reasons ?? this.reasons,
      media: media ?? this.media,
      primaryMediaId: clearPrimaryMediaId
          ? null
          : (primaryMediaId ?? this.primaryMediaId),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'reasons': reasons,
      'media': media.map((item) => item.toMap()).toList(),
      'primaryMediaId': primaryMediaId,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MyReasonsState.fromMap(Map<String, dynamic> map) {
    final rawReasons = map['reasons'];
    final reasons = rawReasons is List
        ? rawReasons
            .whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList()
        : <String>[];
    final rawMedia = map['media'];
    final media = <ReasonMediaItem>[];
    if (rawMedia is List) {
      for (final item in rawMedia) {
        if (item is Map) {
          media.add(
            ReasonMediaItem.fromMap(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          );
        }
      }
    }
    return MyReasonsState(
      reasons: reasons,
      media: media.where((item) => item.id.isNotEmpty && item.path.isNotEmpty).toList(),
      primaryMediaId: map['primaryMediaId'] as String?,
      updatedAt: DateTime.tryParse((map['updatedAt'] as String?) ?? ''),
    );
  }
}
