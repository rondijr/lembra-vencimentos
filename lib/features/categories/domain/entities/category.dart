/// Entity: Category (Domínio)
/// Representa uma categoria de prazos com regras de negócio e invariantes
class Category {
  final String id;
  final String name;
  final String iconCode;
  final int colorValue;
  final List<String> subcategories;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.subcategories,
    required this.createdAt,
    this.updatedAt,
  }) {
    _validate();
  }

  /// Invariantes de domínio
  void _validate() {
    if (id.isEmpty) {
      throw ArgumentError('Category ID cannot be empty');
    }
    if (name.isEmpty || name.length > 50) {
      throw ArgumentError('Category name must be between 1 and 50 characters');
    }
    if (subcategories.isEmpty) {
      throw ArgumentError('Category must have at least one subcategory');
    }
    if (subcategories.length > 20) {
      throw ArgumentError('Category cannot have more than 20 subcategories');
    }
    if (updatedAt != null && updatedAt!.isBefore(createdAt)) {
      throw ArgumentError('Updated date cannot be before created date');
    }
  }

  /// Regra de negócio: verifica se categoria está ativa (atualizada nos últimos 365 dias)
  bool get isActive {
    final referenceDate = updatedAt ?? createdAt;
    final daysSinceUpdate = DateTime.now().difference(referenceDate).inDays;
    return daysSinceUpdate <= 365;
  }

  /// Regra de negócio: verifica se tem subcategorias suficientes
  bool get hasMinimumSubcategories => subcategories.length >= 3;

  /// Regra de negócio: adiciona subcategoria validando duplicação
  Category addSubcategory(String subcategory) {
    if (subcategories.contains(subcategory)) {
      throw ArgumentError('Subcategory "$subcategory" already exists');
    }
    return Category(
      id: id,
      name: name,
      iconCode: iconCode,
      colorValue: colorValue,
      subcategories: [...subcategories, subcategory],
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name, subcategories: ${subcategories.length})';
}
