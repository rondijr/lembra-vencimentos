import '../../domain/entities/tag.dart';
import '../dtos/tag_dto.dart';

/// Mapper: TagMapper
/// Conversões e normalizações entre Entity e DTO
class TagMapper {
  /// Converte DTO para Entity (backend → domínio)
  static Tag toEntity(TagDto dto) {
    return Tag(
      id: dto.id,
      name: _normalizeName(dto.name),
      colorHex: _normalizeColorHex(dto.color_hex),
      userId: dto.user_id,
      deadlineIds: _normalizeDeadlineIds(dto.deadline_ids),
      createdAt: DateTime.parse(dto.created_at),
      updatedAt: dto.updated_at != null ? DateTime.parse(dto.updated_at!) : null,
    );
  }

  /// Converte Entity para DTO (domínio → backend)
  static TagDto toDto(Tag entity) {
    return TagDto(
      id: entity.id,
      name: entity.name,
      color_hex: entity.colorHex,
      user_id: entity.userId,
      deadline_ids: entity.deadlineIds,
      created_at: entity.createdAt.toIso8601String(),
      updated_at: entity.updatedAt?.toIso8601String(),
    );
  }

  /// Normalização: remove espaços extras e capitaliza
  static String _normalizeName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Normalização: garante formato #RRGGBB ou #AARRGGBB
  static String _normalizeColorHex(String hex) {
    final normalized = hex.trim().toUpperCase();
    if (!normalized.startsWith('#')) {
      return '#$normalized';
    }
    return normalized;
  }

  /// Normalização: remove duplicados e IDs vazios
  static List<String> _normalizeDeadlineIds(List<String> ids) {
    return ids
        .where((id) => id.trim().isNotEmpty)
        .map((id) => id.trim())
        .toSet()
        .toList();
  }

  /// Conversão em lote
  static List<Tag> toEntityList(List<TagDto> dtos) {
    return dtos.map((dto) => toEntity(dto)).toList();
  }

  static List<TagDto> toDtoList(List<Tag> entities) {
    return entities.map((entity) => toDto(entity)).toList();
  }
}
