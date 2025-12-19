class Wish {
  final int? id;
  final int letterId;
  final String title;
  final String category;

  Wish({
    this.id,
    required this.letterId,
    required this.title,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'letter_id': letterId,
      'title': title,
      'category': category,
    };
  }

  factory Wish.fromMap(Map<String, dynamic> map) {
    return Wish(
      id: map['id'] as int?,
      letterId: map['letter_id'] as int,
      title: map['title'] as String,
      category: map['category'] as String,
    );
  }
}
