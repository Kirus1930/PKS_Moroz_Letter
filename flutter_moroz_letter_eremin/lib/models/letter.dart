import 'dart:convert';

class Letter {
  int? id;
  final String childName;
  final int age;
  final String story;
  final List<String> wishes;
  final String? drawingPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isSent;
  bool hasResponse;
  String? responseText;
  DateTime? responseDate;

  Letter({
    this.id,
    required this.childName,
    required this.age,
    required this.story,
    required this.wishes,
    this.drawingPath,
    required this.createdAt,
    required this.updatedAt,
    this.isSent = false,
    this.hasResponse = false,
    this.responseText,
    this.responseDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'child_name': childName,
      'age': age,
      'story': story,
      'wishes': jsonEncode(wishes),
      'drawing_path': drawingPath,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_sent': isSent ? 1 : 0,
      'has_response': hasResponse ? 1 : 0,
      'response_text': responseText,
      'response_date': responseDate?.millisecondsSinceEpoch,
    };
  }

  factory Letter.fromMap(Map<String, dynamic> map) {
    return Letter(
      id: map['id'],
      childName: map['child_name'],
      age: map['age'],
      story: map['story'],
      wishes: List<String>.from(jsonDecode(map['wishes'])),
      drawingPath: map['drawing_path'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      isSent: map['is_sent'] == 1,
      hasResponse: map['has_response'] == 1,
      responseText: map['response_text'],
      responseDate: map['response_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['response_date'])
          : null,
    );
  }

  Letter copyWith({
    int? id,
    String? childName,
    int? age,
    String? story,
    List<String>? wishes,
    String? drawingPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSent,
    bool? hasResponse,
    String? responseText,
    DateTime? responseDate,
  }) {
    return Letter(
      id: id ?? this.id,
      childName: childName ?? this.childName,
      age: age ?? this.age,
      story: story ?? this.story,
      wishes: wishes ?? this.wishes,
      drawingPath: drawingPath ?? this.drawingPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSent: isSent ?? this.isSent,
      hasResponse: hasResponse ?? this.hasResponse,
      responseText: responseText ?? this.responseText,
      responseDate: responseDate ?? this.responseDate,
    );
  }
}
