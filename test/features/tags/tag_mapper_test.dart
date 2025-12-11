import 'package:flutter_test/flutter_test.dart';
import 'package:lembra_vencimentos/features/tags/domain/entities/tag.dart';
import 'package:lembra_vencimentos/features/tags/data/dtos/tag_dto.dart';
import 'package:lembra_vencimentos/features/tags/data/mappers/tag_mapper.dart';

void main() {
  group('TagMapper', () {
    test('toEntity converte DTO para Entity com normalização', () {
      // Arrange
      final dto = TagDto(
        id: 'tag-001',
        name: '  Trabalho  ', // espaços extras
        color_hex: 'FF5722', // sem #
        user_id: 'user-123',
        deadline_ids: ['deadline-1', 'deadline-2', 'deadline-1', ''], // duplicata e vazio
        created_at: '2025-12-01T10:00:00Z',
        updated_at: null,
      );

      // Act
      final entity = TagMapper.toEntity(dto);

      // Assert
      expect(entity.id, 'tag-001');
      expect(entity.name, 'Trabalho'); // espaços removidos
      expect(entity.colorHex, '#FF5722'); // # adicionado
      expect(entity.userId, 'user-123');
      expect(entity.deadlineIds, ['deadline-1', 'deadline-2']); // sem duplicata nem vazio
      expect(entity.createdAt, DateTime.parse('2025-12-01T10:00:00Z'));
      expect(entity.updatedAt, null);
    });

    test('toDto converte Entity para DTO corretamente', () {
      // Arrange
      final entity = Tag(
        id: 'tag-002',
        name: 'Pessoal',
        colorHex: '#2196F3',
        userId: 'user-456',
        deadlineIds: ['deadline-3', 'deadline-4', 'deadline-5'],
        createdAt: DateTime.parse('2025-12-05T15:00:00Z'),
        updatedAt: DateTime.parse('2025-12-10T18:00:00Z'),
      );

      // Act
      final dto = TagMapper.toDto(entity);

      // Assert
      expect(dto.id, 'tag-002');
      expect(dto.name, 'Pessoal');
      expect(dto.color_hex, '#2196F3');
      expect(dto.user_id, 'user-456');
      expect(dto.deadline_ids, ['deadline-3', 'deadline-4', 'deadline-5']);
      expect(dto.created_at, '2025-12-05T15:00:00.000Z');
      expect(dto.updated_at, '2025-12-10T18:00:00.000Z');
    });

    test('normalização de cor funciona corretamente', () {
      // Arrange
      final dto1 = TagDto(
        id: 'tag-003',
        name: 'Tag1',
        color_hex: 'ff9800', // minúsculo sem #
        user_id: 'user-789',
        deadline_ids: [],
        created_at: '2025-12-01T10:00:00Z',
      );

      final dto2 = TagDto(
        id: 'tag-004',
        name: 'Tag2',
        color_hex: '#4CAF50', // já com #
        user_id: 'user-789',
        deadline_ids: [],
        created_at: '2025-12-01T10:00:00Z',
      );

      // Act
      final entity1 = TagMapper.toEntity(dto1);
      final entity2 = TagMapper.toEntity(dto2);

      // Assert
      expect(entity1.colorHex, '#FF9800'); // maiúsculo com #
      expect(entity2.colorHex, '#4CAF50'); // manteve #
    });

    test('conversão bidirecional mantém dados (DTO → Entity → DTO)', () {
      // Arrange
      final originalDto = TagDto(
        id: 'tag-005',
        name: 'Urgente',
        color_hex: '#F44336',
        user_id: 'user-abc',
        deadline_ids: ['deadline-10', 'deadline-20'],
        created_at: '2025-12-08T12:00:00Z',
        updated_at: null,
      );

      // Act
      final entity = TagMapper.toEntity(originalDto);
      final resultDto = TagMapper.toDto(entity);

      // Assert
      expect(resultDto.id, originalDto.id);
      expect(resultDto.name, originalDto.name);
      expect(resultDto.color_hex, originalDto.color_hex);
      expect(resultDto.user_id, originalDto.user_id);
      expect(resultDto.deadline_ids, originalDto.deadline_ids);
      expect(resultDto.updated_at, originalDto.updated_at);
    });

    test('conversão bidirecional mantém dados (Entity → DTO → Entity)', () {
      // Arrange
      final originalEntity = Tag(
        id: 'tag-006',
        name: 'Estudos',
        colorHex: '#9C27B0',
        userId: 'user-def',
        deadlineIds: ['deadline-30'],
        createdAt: DateTime.parse('2025-12-10T08:00:00Z'),
        updatedAt: null,
      );

      // Act
      final dto = TagMapper.toDto(originalEntity);
      final resultEntity = TagMapper.toEntity(dto);

      // Assert
      expect(resultEntity.id, originalEntity.id);
      expect(resultEntity.name, originalEntity.name);
      expect(resultEntity.colorHex, originalEntity.colorHex);
      expect(resultEntity.userId, originalEntity.userId);
      expect(resultEntity.deadlineIds, originalEntity.deadlineIds);
      expect(resultEntity.createdAt.toIso8601String(),
          originalEntity.createdAt.toIso8601String());
      expect(resultEntity.updatedAt, originalEntity.updatedAt);
    });

    test('conversão em lote funciona corretamente', () {
      // Arrange
      final dtos = [
        TagDto(
          id: 'tag-007',
          name: 'Tag A',
          color_hex: '#FF0000',
          user_id: 'user-1',
          deadline_ids: [],
          created_at: '2025-12-01T10:00:00Z',
        ),
        TagDto(
          id: 'tag-008',
          name: 'Tag B',
          color_hex: '#00FF00',
          user_id: 'user-1',
          deadline_ids: ['deadline-1'],
          created_at: '2025-12-02T10:00:00Z',
        ),
      ];

      // Act
      final entities = TagMapper.toEntityList(dtos);
      final resultDtos = TagMapper.toDtoList(entities);

      // Assert
      expect(entities.length, 2);
      expect(resultDtos.length, 2);
      expect(resultDtos[0].id, 'tag-007');
      expect(resultDtos[1].id, 'tag-008');
    });

    test('invariante de Entity valida nome vazio', () {
      // Arrange
      final invalidDto = TagDto(
        id: 'tag-invalid',
        name: '', // inválido
        color_hex: '#FF0000',
        user_id: 'user-123',
        deadline_ids: [],
        created_at: '2025-12-01T10:00:00Z',
      );

      // Act & Assert
      expect(
        () => TagMapper.toEntity(invalidDto),
        throwsArgumentError,
      );
    });

    test('invariante de Entity valida cor hexadecimal', () {
      // Arrange
      final invalidDto = TagDto(
        id: 'tag-invalid',
        name: 'Test',
        color_hex: 'ZZZZZZ', // cor inválida
        user_id: 'user-123',
        deadline_ids: [],
        created_at: '2025-12-01T10:00:00Z',
      );

      // Act & Assert
      expect(
        () => TagMapper.toEntity(invalidDto),
        throwsArgumentError,
      );
    });
  });
}
