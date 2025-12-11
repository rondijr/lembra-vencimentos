import 'package:flutter_test/flutter_test.dart';
import 'package:lembra_vencimentos/features/categories/domain/entities/category.dart';
import 'package:lembra_vencimentos/features/categories/data/dtos/category_dto.dart';
import 'package:lembra_vencimentos/features/categories/data/mappers/category_mapper.dart';

void main() {
  group('CategoryMapper', () {
    test('toEntity converte DTO para Entity corretamente', () {
      // Arrange
      final dto = CategoryDto(
        id: 'cat-001',
        name: 'Documentos  Pessoais', // com espaços extras para testar normalização
        icon_code: 'badge',
        color_value: 0xFF2563EB,
        subcategories: ['RG', 'CPF', 'RG', 'CNH'], // com duplicata
        created_at: '2025-01-01T10:00:00Z',
        updated_at: '2025-01-15T14:30:00Z',
      );

      // Act
      final entity = CategoryMapper.toEntity(dto);

      // Assert
      expect(entity.id, 'cat-001');
      expect(entity.name, 'Documentos Pessoais'); // normalizado
      expect(entity.iconCode, 'badge');
      expect(entity.colorValue, 0xFF2563EB);
      expect(entity.subcategories, ['CNH', 'CPF', 'RG']); // duplicata removida e ordenado
      expect(entity.createdAt, DateTime.parse('2025-01-01T10:00:00Z'));
      expect(entity.updatedAt, DateTime.parse('2025-01-15T14:30:00Z'));
    });

    test('toDto converte Entity para DTO corretamente', () {
      // Arrange
      final entity = Category(
        id: 'cat-002',
        name: 'Saúde',
        iconCode: 'favorite',
        colorValue: 0xFFEF4444,
        subcategories: ['Consulta', 'Exame', 'Vacina'],
        createdAt: DateTime.parse('2025-02-01T08:00:00Z'),
        updatedAt: DateTime.parse('2025-02-20T16:45:00Z'),
      );

      // Act
      final dto = CategoryMapper.toDto(entity);

      // Assert
      expect(dto.id, 'cat-002');
      expect(dto.name, 'Saúde');
      expect(dto.icon_code, 'favorite');
      expect(dto.color_value, 0xFFEF4444);
      expect(dto.subcategories, ['Consulta', 'Exame', 'Vacina']);
      expect(dto.created_at, '2025-02-01T08:00:00.000Z');
      expect(dto.updated_at, '2025-02-20T16:45:00.000Z');
    });

    test('conversão bidirecional mantém dados (DTO → Entity → DTO)', () {
      // Arrange
      final originalDto = CategoryDto(
        id: 'cat-003',
        name: 'Financeiro',
        icon_code: 'attach_money',
        color_value: 0xFF10B981,
        subcategories: ['Aluguel', 'Boleto', 'Cartão'],
        created_at: '2025-03-10T12:00:00Z',
        updated_at: null,
      );

      // Act
      final entity = CategoryMapper.toEntity(originalDto);
      final resultDto = CategoryMapper.toDto(entity);

      // Assert
      expect(resultDto.id, originalDto.id);
      expect(resultDto.name, originalDto.name);
      expect(resultDto.icon_code, originalDto.icon_code);
      expect(resultDto.color_value, originalDto.color_value);
      expect(resultDto.subcategories, ['Aluguel', 'Boleto', 'Cartão']); // mantém ordem
      expect(resultDto.updated_at, null);
    });

    test('conversão bidirecional mantém dados (Entity → DTO → Entity)', () {
      // Arrange
      final originalEntity = Category(
        id: 'cat-004',
        name: 'Veículos',
        iconCode: 'directions_car',
        colorValue: 0xFF8B5CF6,
        subcategories: ['IPVA', 'Licenciamento', 'Seguro Auto'],
        createdAt: DateTime.parse('2025-04-05T09:30:00Z'),
        updatedAt: null,
      );

      // Act
      final dto = CategoryMapper.toDto(originalEntity);
      final resultEntity = CategoryMapper.toEntity(dto);

      // Assert
      expect(resultEntity.id, originalEntity.id);
      expect(resultEntity.name, originalEntity.name);
      expect(resultEntity.iconCode, originalEntity.iconCode);
      expect(resultEntity.colorValue, originalEntity.colorValue);
      expect(resultEntity.subcategories, ['IPVA', 'Licenciamento', 'Seguro Auto']);
      expect(resultEntity.createdAt, originalEntity.createdAt);
      expect(resultEntity.updatedAt, originalEntity.updatedAt);
    });

    test('toEntityList converte lista de DTOs corretamente', () {
      // Arrange
      final dtos = [
        CategoryDto(
          id: 'cat-001',
          name: 'Cat1',
          icon_code: 'icon1',
          color_value: 0xFF000001,
          subcategories: ['Sub1'],
          created_at: '2025-01-01T10:00:00Z',
        ),
        CategoryDto(
          id: 'cat-002',
          name: 'Cat2',
          icon_code: 'icon2',
          color_value: 0xFF000002,
          subcategories: ['Sub2'],
          created_at: '2025-01-02T10:00:00Z',
        ),
      ];

      // Act
      final entities = CategoryMapper.toEntityList(dtos);

      // Assert
      expect(entities.length, 2);
      expect(entities[0].id, 'cat-001');
      expect(entities[1].id, 'cat-002');
    });

    test('invariante de Entity é validada após conversão', () {
      // Arrange - DTO com nome vazio (inválido no domínio)
      final invalidDto = CategoryDto(
        id: 'cat-invalid',
        name: '', // nome vazio
        icon_code: 'icon',
        color_value: 0xFF000000,
        subcategories: ['Sub1'],
        created_at: '2025-01-01T10:00:00Z',
      );

      // Act & Assert
      expect(
        () => CategoryMapper.toEntity(invalidDto),
        throwsArgumentError,
      );
    });
  });
}
