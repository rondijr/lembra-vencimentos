import 'package:flutter/material.dart';

class DeadlineCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<String> subcategories;

  const DeadlineCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.subcategories,
  });
}

class Categories {
  static const documentos = DeadlineCategory(
    id: 'documentos',
    name: 'Documentos',
    icon: Icons.badge_outlined,
    color: Color(0xFF2563EB), // Blue
    subcategories: ['RG', 'CNH', 'Passaporte', 'Carteira de Trabalho', 'CPF'],
  );

  static const saude = DeadlineCategory(
    id: 'saude',
    name: 'Saúde',
    icon: Icons.favorite_outline,
    color: Color(0xFFEF4444), // Red
    subcategories: ['Vacina', 'Exame', 'Consulta', 'Receita Médica', 'Óculos'],
  );

  static const financeiro = DeadlineCategory(
    id: 'financeiro',
    name: 'Financeiro',
    icon: Icons.attach_money,
    color: Color(0xFF10B981), // Green
    subcategories: ['Boleto', 'Cartão', 'Imposto', 'Seguro', 'Aluguel'],
  );

  static const veiculos = DeadlineCategory(
    id: 'veiculos',
    name: 'Veículos',
    icon: Icons.directions_car_outlined,
    color: Color(0xFF8B5CF6), // Purple
    subcategories: ['Licenciamento', 'Revisão', 'Seguro', 'IPVA', 'Vistoria'],
  );

  static const casa = DeadlineCategory(
    id: 'casa',
    name: 'Casa',
    icon: Icons.home_outlined,
    color: Color(0xFFF59E0B), // Amber
    subcategories: ['Garantia', 'Manutenção', 'Contrato', 'IPTU', 'Condomínio'],
  );

  static const educacao = DeadlineCategory(
    id: 'educacao',
    name: 'Educação',
    icon: Icons.school_outlined,
    color: Color(0xFF06B6D4), // Cyan
    subcategories: [
      'Matrícula',
      'Mensalidade',
      'Prova',
      'Trabalho',
      'Certificação'
    ],
  );

  static const pets = DeadlineCategory(
    id: 'pets',
    name: 'Pets',
    icon: Icons.pets_outlined,
    color: Color(0xFFEC4899), // Pink
    subcategories: ['Vacina', 'Vermífugo', 'Banho', 'Consulta', 'Ração'],
  );

  static const outros = DeadlineCategory(
    id: 'outros',
    name: 'Outros',
    icon: Icons.more_horiz,
    color: Color(0xFF6B7280), // Gray
    subcategories: ['Geral'],
  );

  static const List<DeadlineCategory> all = [
    documentos,
    saude,
    financeiro,
    veiculos,
    casa,
    educacao,
    pets,
    outros,
  ];

  static DeadlineCategory getById(String id) {
    return all.firstWhere(
      (cat) => cat.id == id,
      orElse: () => outros,
    );
  }

  static DeadlineCategory? findBySubcategory(String subcategory) {
    for (var category in all) {
      if (category.subcategories.contains(subcategory)) {
        return category;
      }
    }
    return null;
  }

  static Color getColorForSubcategory(String subcategory) {
    final category = findBySubcategory(subcategory);
    return category?.color ?? outros.color;
  }

  static IconData getIconForSubcategory(String subcategory) {
    final category = findBySubcategory(subcategory);
    return category?.icon ?? outros.icon;
  }
}
