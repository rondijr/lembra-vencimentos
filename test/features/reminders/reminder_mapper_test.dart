import 'package:flutter_test/flutter_test.dart';
import 'package:lembra_vencimentos/features/reminders/domain/entities/reminder.dart';
import 'package:lembra_vencimentos/features/reminders/data/dtos/reminder_dto.dart';
import 'package:lembra_vencimentos/features/reminders/data/mappers/reminder_mapper.dart';

void main() {
  group('ReminderMapper', () {
    test('toEntity converte DTO para Entity corretamente', () {
      // Arrange
      final dto = ReminderDto(
        id: 'remind-001',
        user_id: 'user-123',
        deadline_id: 'deadline-456',
        days_before: 7,
        time_of_day: '09:00',
        is_active: true,
        frequency: 'once',
        created_at: '2025-12-01T10:00:00Z',
        last_sent_at: null,
      );

      // Act
      final entity = ReminderMapper.toEntity(dto);

      // Assert
      expect(entity.id, 'remind-001');
      expect(entity.userId, 'user-123');
      expect(entity.deadlineId, 'deadline-456');
      expect(entity.daysBefore, 7);
      expect(entity.timeOfDay.hour, 9);
      expect(entity.timeOfDay.minute, 0);
      expect(entity.isActive, true);
      expect(entity.frequency, ReminderFrequency.once);
      expect(entity.createdAt, DateTime.parse('2025-12-01T10:00:00Z'));
      expect(entity.lastSentAt, null);
    });

    test('toDto converte Entity para DTO corretamente', () {
      // Arrange
      final entity = Reminder(
        id: 'remind-002',
        userId: 'user-789',
        deadlineId: 'deadline-012',
        daysBefore: 3,
        timeOfDay: TimeOfDay(hour: 14, minute: 30),
        isActive: false,
        frequency: ReminderFrequency.daily,
        createdAt: DateTime.parse('2025-12-05T15:00:00Z'),
        lastSentAt: DateTime.parse('2025-12-10T14:30:00Z'),
      );

      // Act
      final dto = ReminderMapper.toDto(entity);

      // Assert
      expect(dto.id, 'remind-002');
      expect(dto.user_id, 'user-789');
      expect(dto.deadline_id, 'deadline-012');
      expect(dto.days_before, 3);
      expect(dto.time_of_day, '14:30');
      expect(dto.is_active, false);
      expect(dto.frequency, 'daily');
      expect(dto.created_at, '2025-12-05T15:00:00.000Z');
      expect(dto.last_sent_at, '2025-12-10T14:30:00.000Z');
    });

    test('TimeOfDay parsing e formatting funciona corretamente', () {
      // Arrange & Act & Assert
      final time1 = TimeOfDay(hour: 8, minute: 0);
      expect(time1.toFormattedString(), '08:00');

      final time2 = TimeOfDay(hour: 23, minute: 59);
      expect(time2.toFormattedString(), '23:59');

      final time3 = TimeOfDay.fromString('15:45');
      expect(time3.hour, 15);
      expect(time3.minute, 45);
    });

    test('conversão bidirecional mantém dados (DTO → Entity → DTO)', () {
      // Arrange
      final originalDto = ReminderDto(
        id: 'remind-003',
        user_id: 'user-abc',
        deadline_id: 'deadline-xyz',
        days_before: 14,
        time_of_day: '10:15',
        is_active: true,
        frequency: 'weekly',
        created_at: '2025-12-08T12:00:00Z',
        last_sent_at: null,
      );

      // Act
      final entity = ReminderMapper.toEntity(originalDto);
      final resultDto = ReminderMapper.toDto(entity);

      // Assert
      expect(resultDto.id, originalDto.id);
      expect(resultDto.user_id, originalDto.user_id);
      expect(resultDto.deadline_id, originalDto.deadline_id);
      expect(resultDto.days_before, originalDto.days_before);
      expect(resultDto.time_of_day, originalDto.time_of_day);
      expect(resultDto.is_active, originalDto.is_active);
      expect(resultDto.frequency, originalDto.frequency);
      expect(resultDto.last_sent_at, originalDto.last_sent_at);
    });

    test('conversão bidirecional mantém dados (Entity → DTO → Entity)', () {
      // Arrange
      final originalEntity = Reminder(
        id: 'remind-004',
        userId: 'user-def',
        deadlineId: 'deadline-ghi',
        daysBefore: 1,
        timeOfDay: TimeOfDay(hour: 7, minute: 0),
        isActive: true,
        frequency: ReminderFrequency.monthly,
        createdAt: DateTime.parse('2025-12-10T08:00:00Z'),
        lastSentAt: null,
      );

      // Act
      final dto = ReminderMapper.toDto(originalEntity);
      final resultEntity = ReminderMapper.toEntity(dto);

      // Assert
      expect(resultEntity.id, originalEntity.id);
      expect(resultEntity.userId, originalEntity.userId);
      expect(resultEntity.deadlineId, originalEntity.deadlineId);
      expect(resultEntity.daysBefore, originalEntity.daysBefore);
      expect(resultEntity.timeOfDay.hour, originalEntity.timeOfDay.hour);
      expect(resultEntity.timeOfDay.minute, originalEntity.timeOfDay.minute);
      expect(resultEntity.isActive, originalEntity.isActive);
      expect(resultEntity.frequency, originalEntity.frequency);
    });

    test('ReminderFrequency enum conversão funciona corretamente', () {
      // Arrange & Act & Assert
      expect(ReminderFrequency.fromString('once'), ReminderFrequency.once);
      expect(ReminderFrequency.fromString('DAILY'), ReminderFrequency.daily);
      expect(ReminderFrequency.fromString('Weekly'), ReminderFrequency.weekly);
      expect(ReminderFrequency.fromString('MONTHLY'), ReminderFrequency.monthly);
      expect(ReminderFrequency.fromString('invalid'), ReminderFrequency.once); // fallback
    });

    test('invariante de Entity valida daysBefore', () {
      // Arrange - daysBefore negativo (inválido)
      final invalidDto = ReminderDto(
        id: 'remind-invalid',
        user_id: 'user-123',
        deadline_id: 'deadline-456',
        days_before: -1, // inválido
        time_of_day: '09:00',
        is_active: true,
        frequency: 'once',
        created_at: '2025-12-01T10:00:00Z',
      );

      // Act & Assert
      expect(
        () => ReminderMapper.toEntity(invalidDto),
        throwsArgumentError,
      );
    });

    test('parsing de TimeOfDay inválido lança exceção', () {
      // Arrange
      final invalidDto = ReminderDto(
        id: 'remind-invalid',
        user_id: 'user-123',
        deadline_id: 'deadline-456',
        days_before: 1,
        time_of_day: 'invalid-time', // formato inválido
        is_active: true,
        frequency: 'once',
        created_at: '2025-12-01T10:00:00Z',
      );

      // Act & Assert
      expect(
        () => ReminderMapper.toEntity(invalidDto),
        throwsFormatException,
      );
    });
  });
}
