/// DTO: CategoryDto (Espelho do schema remoto/Supabase)
/// Estrutura de dados que reflete exatamente o schema do backend
class CategoryDto {
  final String id;
  final String name;
  final String icon_code; // snake_case do backend
  final int color_value;  // snake_case do backend
  final List<String> subcategories;
  final String created_at; // ISO 8601 string
  final String? updated_at; // ISO 8601 string, nullable

  const CategoryDto({
    required this.id,
    required this.name,
    required this.icon_code,
    required this.color_value,
    required this.subcategories,
    required this.created_at,
    this.updated_at,
  });

  /// Serialização para JSON (envio ao backend)
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon_code': icon_code,
        'color_value': color_value,
        'subcategories': subcategories,
        'created_at': created_at,
        if (updated_at != null) 'updated_at': updated_at,
      };

  /// Desserialização do JSON (recebimento do backend)
  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      icon_code: json['icon_code'] as String,
      color_value: json['color_value'] as int,
      subcategories: (json['subcategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      created_at: json['created_at'] as String,
      updated_at: json['updated_at'] as String?,
    );
  }

  @override
  String toString() => 'CategoryDto(id: $id, name: $name)';
}
