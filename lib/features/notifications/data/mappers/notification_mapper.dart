import '../../domain/entities/notification.dart';
import '../dtos/notification_dto.dart';

/// Mapper: NotificationMapper
/// Conversões e normalizações entre Entity e DTO
class NotificationMapper {
  /// Converte DTO para Entity (backend → domínio)
  static Notification toEntity(NotificationDto dto) {
    return Notification(
      id: dto.id,
      deadlineId: dto.deadline_id,
      userId: dto.user_id,
      title: _normalizeText(dto.title),
      body: _normalizeText(dto.body),
      scheduledFor: DateTime.parse(dto.scheduled_for),
      isSent: dto.is_sent,
      sentAt: dto.sent_at != null ? DateTime.parse(dto.sent_at!) : null,
      priority: NotificationPriority.fromString(dto.priority),
      createdAt: DateTime.parse(dto.created_at),
    );
  }

  /// Converte Entity para DTO (domínio → backend)
  static NotificationDto toDto(Notification entity) {
    return NotificationDto(
      id: entity.id,
      deadline_id: entity.deadlineId,
      user_id: entity.userId,
      title: entity.title,
      body: entity.body,
      scheduled_for: entity.scheduledFor.toIso8601String(),
      is_sent: entity.isSent,
      sent_at: entity.sentAt?.toIso8601String(),
      priority: entity.priority.value,
      created_at: entity.createdAt.toIso8601String(),
    );
  }

  /// Normalização: remove espaços extras
  static String _normalizeText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Conversão em lote
  static List<Notification> toEntityList(List<NotificationDto> dtos) {
    return dtos.map((dto) => toEntity(dto)).toList();
  }

  static List<NotificationDto> toDtoList(List<Notification> entities) {
    return entities.map((entity) => toDto(entity)).toList();
  }
}
