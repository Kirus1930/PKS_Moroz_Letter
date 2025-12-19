import 'wish.dart';

class Letter {
  final int? id;
  final String childName;
  final int age;
  final String story;
  final List<Wish> wishes;
  final String? drawingPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final bool isSent;

  Letter({
    this.id,
    required this.childName,
    required this.age,
    required this.story,
    required this.wishes,
    this.drawingPath,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.isSent = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'child_name': childName,
      'age': age,
      'story': story,
      'drawing_path': drawingPath,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_favorite': isFavorite ? 1 : 0,
      'is_sent': isSent ? 1 : 0,
    };
  }

  factory Letter.fromMap(Map<String, dynamic> map) {
    return Letter(
      id: map['id'] as int?,
      childName: map['child_name'] as String,
      age: map['age'] as int,
      story: map['story'] as String,
      wishes: [], // Загружаем отдельно через DAO
      drawingPath: map['drawing_path'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      isFavorite: (map['is_favorite'] as int) == 1,
      isSent: (map['is_sent'] as int) == 1,
    );
  }
}
