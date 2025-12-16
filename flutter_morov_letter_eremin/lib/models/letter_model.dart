class Letter {
  final String id;
  final String childName;
  final int age;
  final String story;
  final String moodEmoji;
  final List<String> wishes;
  final List<String> categories;
  final String? drawingPath;
  final String? photoPath;
  final DateTime createdAt;
  final bool isSent;
  final String? secretGiftFromParent;

  Letter({
    required this.id,
    required this.childName,
    required this.age,
    required this.story,
    required this.moodEmoji,
    required this.wishes,
    required this.categories,
    this.drawingPath,
    this.photoPath,
    required this.createdAt,
    this.isSent = false,
    this.secretGiftFromParent,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'childName': childName,
    'age': age,
    'story': story,
    'moodEmoji': moodEmoji,
    'wishes': wishes,
    'categories': categories,
    'drawingPath': drawingPath,
    'photoPath': photoPath,
    'createdAt': createdAt.toIso8601String(),
    'isSent': isSent,
    'secretGiftFromParent': secretGiftFromParent,
  };

  factory Letter.fromJson(Map<String, dynamic> json) => Letter(
    id: json['id'],
    childName: json['childName'],
    age: json['age'],
    story: json['story'],
    moodEmoji: json['moodEmoji'],
    wishes: List<String>.from(json['wishes']),
    categories: List<String>.from(json['categories']),
    drawingPath: json['drawingPath'],
    photoPath: json['photoPath'],
    createdAt: DateTime.parse(json['createdAt']),
    isSent: json['isSent'],
    secretGiftFromParent: json['secretGiftFromParent'],
  );
}
