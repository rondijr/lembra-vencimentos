/// DTO: TagDto (Espelho do schema remoto/Supabase)
class TagDto {
  final String id;
  final String name;
  final String color_hex;     // snake_case do backend
  final String user_id;       // snake_case do backend
  final List<String> deadline_ids; // snake_case do backend
  final String created_at;    // ISO 8601 string
  final String? updated_at;   // ISO 8601 string, nullable

  const TagDto({
    required this.id,
    required this.name,
    required this.color_hex,
    required this.user_id,
    required this.deadline_ids,
    required this.created_at,
    this.updated_at,
  });

  /// Serialização para JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color_hex': color_hex,
        'user_id': user_id,
        'deadline_ids': deadline_ids,
        'created_at': created_at,
        if (updated_at != null) 'updated_at': updated_at,
      };

  /// Desserialização do JSON
  factory TagDto.fromJson(Map<String, dynamic> json) {
    return TagDto(
      id: json['id'] as String,
      name: json['name'] as String,
      color_hex: json['color_hex'] as String,
      user_id: json['user_id'] as String,
      deadline_ids: (json['deadline_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      created_at: json['created_at'] as String,
      updated_at: json['updated_at'] as String?,
    );
  }

  @override
  String toString() => 'TagDto(id: $id, name: $name, deadlines: ${deadline_ids.length})';
}
