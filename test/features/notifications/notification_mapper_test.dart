import 'package:flutter_test/flutter_test.dart';
import 'package:lembra_vencimentos/features/notifications/domain/entities/notification.dart';
import 'package:lembra_vencimentos/features/notifications/data/dtos/notification_dto.dart';
import 'package:lembra_vencimentos/features/notifications/data/mappers/notification_mapper.dart';

void main() {
  group('NotificationMapper', () {
    test('toEntity converte DTO para Entity corretamente', () {
      // Arrange
      final dto = NotificationDto(
        id: 'notif-001',
        deadline_id: 'deadline-123',
        user_id: 'user-456',
        title: 'Lembrete   Importante', // espaços extras
        body: 'Seu  prazo  vence  amanhã', // espaços extras
        scheduled_for: '2025-12-15T09:00:00Z',
        is_sent: false,
        sent_at: null,
        priority: 'high',
        created_at: '2025-12-10T10:00:00Z',
      );

      // Act
      final entity = NotificationMapper.toEntity(dto);

      // Assert
      expect(entity.id, 'notif-001');
      expect(entity.deadlineId, 'deadline-123');
      expect(entity.userId, 'user-456');
      expect(entity.title, 'Lembrete Importante'); // normalizado
      expect(entity.body, 'Seu prazo vence amanhã'); // normalizado
      expect(entity.scheduledFor, DateTime.parse('2025-12-15T09:00:00Z'));
      expect(entity.isSent, false);
      expect(entity.sentAt, null);
      expect(entity.priority, NotificationPriority.high);
      expect(entity.createdAt, DateTime.parse('2025-12-10T10:00:00Z'));
    });

    test('toDto converte Entity para DTO corretamente', () {
      // Arrange
      final entity = Notification(
        id: 'notif-002',
        deadlineId: 'deadline-789',
        userId: 'user-012',
        title: 'Prazo Urgente',
        body: 'CNH vence hoje!',
        scheduledFor: DateTime.parse('2025-12-11T08:00:00Z'),
        isSent: true,
        sentAt: DateTime.parse('2025-12-11T08:05:00Z'),
        priority: NotificationPriority.urgent,
        createdAt: DateTime.parse('2025-12-10T15:00:00Z'),
      );

      // Act
      final dto = NotificationMapper.toDto(entity);

      // Assert
      expect(dto.id, 'notif-002');
      expect(dto.deadline_id, 'deadline-789');
      expect(dto.user_id, 'user-012');
      expect(dto.title, 'Prazo Urgente');
      expect(dto.body, 'CNH vence hoje!');
      expect(dto.scheduled_for, '2025-12-11T08:00:00.000Z');
      expect(dto.is_sent, true);
      expect(dto.sent_at, '2025-12-11T08:05:00.000Z');
      expect(dto.priority, 'urgent');
      expect(dto.created_at, '2025-12-10T15:00:00.000Z');
    });

    test('conversão bidirecional mantém dados (DTO → Entity → DTO)', () {
      // Arrange
      final originalDto = NotificationDto(
        id: 'notif-003',
        deadline_id: 'deadline-abc',
        user_id: 'user-xyz',
        title: 'Lembrete',
        body: 'Teste de conversão',
        scheduled_for: '2025-12-20T12:00:00Z',
        is_sent: false,
        sent_at: null,
        priority: 'medium',
        created_at: '2025-12-11T10:00:00Z',
      );

      // Act
      final entity = NotificationMapper.toEntity(originalDto);
      final resultDto = NotificationMapper.toDto(entity);

      // Assert
      expect(resultDto.id, originalDto.id);
      expect(resultDto.deadline_id, originalDto.deadline_id);
      expect(resultDto.user_id, originalDto.user_id);
      expect(resultDto.priority, originalDto.priority);
      expect(resultDto.is_sent, originalDto.is_sent);
      expect(resultDto.sent_at, originalDto.sent_at);
    });

    test('conversão bidirecional mantém dados (Entity → DTO → Entity)', () {
      // Arrange
      final originalEntity = Notification(
        id: 'notif-004',
        deadlineId: 'deadline-def',
        userId: 'user-ghi',
        title: 'Aviso',
        body: 'Prazo próximo',
        scheduledFor: DateTime.parse('2025-12-25T14:00:00Z'),
        isSent: false,
        sentAt: null,
        priority: NotificationPriority.low,
        createdAt: DateTime.parse('2025-12-11T11:00:00Z'),
      );

      // Act
      final dto = NotificationMapper.toDto(originalEntity);
      final resultEntity = NotificationMapper.toEntity(dto);

      // Assert
      expect(resultEntity.id, originalEntity.id);
      expect(resultEntity.deadlineId, originalEntity.deadlineId);
      expect(resultEntity.userId, originalEntity.userId);
      expect(resultEntity.title, originalEntity.title);
      expect(resultEntity.body, originalEntity.body);
      expect(resultEntity.isSent, originalEntity.isSent);
      expect(resultEntity.priority, originalEntity.priority);
    });

    test('NotificationPriority enum conversão funciona corretamente', () {
      // Arrange & Act & Assert
      expect(NotificationPriority.fromString('low'), NotificationPriority.low);
      expect(NotificationPriority.fromString('MEDIUM'), NotificationPriority.medium);
      expect(NotificationPriority.fromString('High'), NotificationPriority.high);
      expect(NotificationPriority.fromString('URGENT'), NotificationPriority.urgent);
      expect(NotificationPriority.fromString('invalid'), NotificationPriority.medium); // fallback
    });

    test('invariante de Entity valida isSent e sentAt', () {
      // Arrange - notificação enviada sem timestamp (inválido)
      final invalidDto = NotificationDto(
        id: 'notif-invalid',
        deadline_id: 'deadline-123',
        user_id: 'user-456',
        title: 'Teste',
        body: 'Corpo',
        scheduled_for: '2025-12-15T09:00:00Z',
        is_sent: true, // marcado como enviado
        sent_at: null, // mas sem timestamp de envio
        priority: 'medium',
        created_at: '2025-12-10T10:00:00Z',
      );

      // Act & Assert
      expect(
        () => NotificationMapper.toEntity(invalidDto),
        throwsArgumentError,
      );
    });
  });
}
