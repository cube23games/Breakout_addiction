enum ReasonMediaType {
  photo,
  video,
}

class ReasonMediaItem {
  const ReasonMediaItem({
    required this.id,
    required this.path,
    required this.type,
    this.caption = '',
  });

  final String id;
  final String path;
  final ReasonMediaType type;
  final String caption;

  ReasonMediaItem copyWith({
    String? id,
    String? path,
    ReasonMediaType? type,
    String? caption,
  }) {
    return ReasonMediaItem(
      id: id ?? this.id,
      path: path ?? this.path,
      type: type ?? this.type,
      caption: caption ?? this.caption,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'path': path,
      'type': type.name,
      'caption': caption,
    };
  }

  factory ReasonMediaItem.fromMap(Map<String, dynamic> map) {
    final rawType = map['type'] as String?;
    final type = ReasonMediaType.values.firstWhere(
      (item) => item.name == rawType,
      orElse: () => ReasonMediaType.photo,
    );
    return ReasonMediaItem(
      id: (map['id'] as String?) ?? '',
      path: (map['path'] as String?) ?? '',
      type: type,
      caption: (map['caption'] as String?) ?? '',
    );
  }
}
