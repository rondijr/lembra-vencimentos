import '../../domain/entities/category.dart';
import '../dtos/category_dto.dart';

/// Mapper: CategoryMapper
/// Responsável APENAS por conversões e normalizações entre Entity e DTO
/// NÃO contém regras de negócio (essas ficam na Entity)
class CategoryMapper {
  /// Converte DTO para Entity (backend → domínio)
  static Category toEntity(CategoryDto dto) {
    return Category(
      id: dto.id,
      name: _normalizeName(dto.name),
      iconCode: dto.icon_code,
      colorValue: dto.color_value,
      subcategories: _normalizeSubcategories(dto.subcategories),
      createdAt: DateTime.parse(dto.created_at),
      updatedAt: dto.updated_at != null ? DateTime.parse(dto.updated_at!) : null,
    );
  }

  /// Converte Entity para DTO (domínio → backend)
  static CategoryDto toDto(Category entity) {
    return CategoryDto(
      id: entity.id,
      name: entity.name,
      icon_code: entity.iconCode,
      color_value: entity.colorValue,
      subcategories: entity.subcategories,
      created_at: entity.createdAt.toIso8601String(),
      updated_at: entity.updatedAt?.toIso8601String(),
    );
  }

  /// Normalização: remove espaços extras e capitaliza nome
  static String _normalizeName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Normalização: remove duplicatas e ordena subcategorias
  static List<String> _normalizeSubcategories(List<String> subcategories) {
    final normalized = subcategories.map((s) => s.trim()).toSet().toList();
    normalized.sort();
    return normalized;
  }

  /// Conversão em lote: lista de DTOs para lista de Entities
  static List<Category> toEntityList(List<CategoryDto> dtos) {
    return dtos.map((dto) => toEntity(dto)).toList();
  }

  /// Conversão em lote: lista de Entities para lista de DTOs
  static List<CategoryDto> toDtoList(List<Category> entities) {
    return entities.map((entity) => toDto(entity)).toList();
  }
}
