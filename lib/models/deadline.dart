import 'dart:convert';

class Deadline {
  final String id;
  final String title;
  final String category; // RG, CNH, Carteirinha, etc.
  final DateTime date;

  Deadline({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
  });

  factory Deadline.fromMap(Map<String, dynamic> m) => Deadline(
        id: m['id'] as String,
        title: m['title'] as String,
        category: m['category'] as String,
        date: DateTime.parse(m['date'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'date': date.toIso8601String(),
      };

  String toJson() => json.encode(toMap());

  factory Deadline.fromJson(String s) => Deadline.fromMap(json.decode(s));
}
