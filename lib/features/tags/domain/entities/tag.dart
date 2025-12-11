/// Entity: Tag (Domínio)
/// Representa uma etiqueta para organizar prazos
class Tag {
  final String id;
  final String name;
  final String colorHex;
  final String userId;
  final List<String> deadlineIds;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Tag({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.userId,
    required this.deadlineIds,
    required this.createdAt,
    this.updatedAt,
  }) {
    _validate();
  }

  /// Invariantes de domínio
  void _validate() {
    if (id.isEmpty) {
      throw ArgumentError('Tag ID cannot be empty');
    }
    if (name.isEmpty || name.length > 30) {
      throw ArgumentError('Tag name must be between 1 and 30 characters');
    }
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    if (!_isValidHexColor(colorHex)) {
      throw ArgumentError('Color must be a valid hex color (#RRGGBB or #AARRGGBB)');
    }
    if (deadlineIds.length > 1000) {
      throw ArgumentError('A tag cannot have more than 1000 deadlines');
    }
    if (updatedAt != null && updatedAt!.isBefore(createdAt)) {
      throw ArgumentError('Updated date cannot be before created date');
    }
  }

  /// Validação de cor hexadecimal
  bool _isValidHexColor(String hex) {
    final pattern = RegExp(r'^#[0-9A-Fa-f]{6}$|^#[0-9A-Fa-f]{8}$');
    return pattern.hasMatch(hex);
  }

  /// Regra de negócio: verifica se tem prazos associados
  bool get hasDeadlines => deadlineIds.isNotEmpty;

  /// Regra de negócio: verifica se está sendo muito usada
  bool get isPopular => deadlineIds.length >= 10;

  /// Regra de negócio: verifica se foi modificada recentemente
  bool get isRecentlyUpdated {
    final dateToCheck = updatedAt ?? createdAt;
    final difference = DateTime.now().difference(dateToCheck);
    return difference.inDays <= 7;
  }

  /// Adiciona prazo à tag
  Tag addDeadline(String deadlineId) {
    if (deadlineId.isEmpty) {
      throw ArgumentError('Deadline ID cannot be empty');
    }
    if (deadlineIds.contains(deadlineId)) {
      return this; // já existe, não adiciona duplicado
    }

    return Tag(
      id: id,
      name: name,
      colorHex: colorHex,
      userId: userId,
      deadlineIds: [...deadlineIds, deadlineId],
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Remove prazo da tag
  Tag removeDeadline(String deadlineId) {
    if (!deadlineIds.contains(deadlineId)) {
      return this; // não existe, nada a fazer
    }

    return Tag(
      id: id,
      name: name,
      colorHex: colorHex,
      userId: userId,
      deadlineIds: deadlineIds.where((id) => id != deadlineId).toList(),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Renomeia tag
  Tag rename(String newName) {
    if (newName.isEmpty || newName.length > 30) {
      throw ArgumentError('Tag name must be between 1 and 30 characters');
    }

    return Tag(
      id: id,
      name: newName.trim(),
      colorHex: colorHex,
      userId: userId,
      deadlineIds: deadlineIds,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Muda cor da tag
  Tag changeColor(String newColorHex) {
    return Tag(
      id: id,
      name: name,
      colorHex: newColorHex,
      userId: userId,
      deadlineIds: deadlineIds,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Tag(id: $id, name: $name, deadlines: ${deadlineIds.length})';
}
