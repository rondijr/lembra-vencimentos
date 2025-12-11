import '../../domain/entities/reminder.dart';
import '../dtos/reminder_dto.dart';

/// Mapper: ReminderMapper
/// Conversões e normalizações entre Entity e DTO
class ReminderMapper {
  /// Converte DTO para Entity (backend → domínio)
  static Reminder toEntity(ReminderDto dto) {
    return Reminder(
      id: dto.id,
      userId: dto.user_id,
      deadlineId: dto.deadline_id,
      daysBefore: dto.days_before,
      timeOfDay: _parseTimeOfDay(dto.time_of_day),
      isActive: dto.is_active,
      frequency: ReminderFrequency.fromString(dto.frequency),
      createdAt: DateTime.parse(dto.created_at),
      lastSentAt: dto.last_sent_at != null ? DateTime.parse(dto.last_sent_at!) : null,
    );
  }

  /// Converte Entity para DTO (domínio → backend)
  static ReminderDto toDto(Reminder entity) {
    return ReminderDto(
      id: entity.id,
      user_id: entity.userId,
      deadline_id: entity.deadlineId,
      days_before: entity.daysBefore,
      time_of_day: _formatTimeOfDay(entity.timeOfDay),
      is_active: entity.isActive,
      frequency: entity.frequency.value,
      created_at: entity.createdAt.toIso8601String(),
      last_sent_at: entity.lastSentAt?.toIso8601String(),
    );
  }

  /// Normalização: converte string "HH:MM" para TimeOfDay
  static TimeOfDay _parseTimeOfDay(String time) {
    final normalized = time.trim();
    final parts = normalized.split(':');
    
    if (parts.length != 2) {
      throw FormatException('Invalid time format: $time. Expected HH:MM');
    }
    
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Normalização: converte TimeOfDay para string "HH:MM"
  static String _formatTimeOfDay(TimeOfDay time) {
    return time.toFormattedString();
  }

  /// Conversão em lote
  static List<Reminder> toEntityList(List<ReminderDto> dtos) {
    return dtos.map((dto) => toEntity(dto)).toList();
  }

  static List<ReminderDto> toDtoList(List<Reminder> entities) {
    return entities.map((entity) => toDto(entity)).toList();
  }
}
