import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/deadline.dart';
import '../../../../core/utils/categories.dart';

class DeadlineListItem extends StatelessWidget {
  final Deadline deadline;
  final VoidCallback onDelete;

  const DeadlineListItem(
      {Key? key, required this.deadline, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    
    final dateStr = DateFormat('dd/MM/yyyy').format(deadline.date);
    final daysUntil = deadline.date.difference(DateTime.now()).inDays;
    final isUrgent = daysUntil <= 7;
    final isPast = daysUntil < 0;

    // Busca categoria e cor
    final category = Categories.findBySubcategory(deadline.category);
    final categoryColor = category?.color ?? Colors.grey;
    final categoryIcon = category?.icon ?? Icons.description;

    // Define cor de urgência sobrepondo a cor da categoria se necessário
    final urgencyColor = isPast
        ? Colors.red
        : isUrgent
            ? Colors.orange
            : categoryColor;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              categoryColor.withValues(alpha: 0.15),
              categoryColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: categoryColor.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone da categoria com cor específica
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: categoryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  categoryIcon,
                  color: categoryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deadline.title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: categoryColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  categoryIcon,
                                  size: 12,
                                  color: categoryColor,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    deadline.category,
                                    style: TextStyle(
                                      color: categoryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: textColor.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Badge de dias restantes
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: urgencyColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPast
                            ? 'VENCIDO'
                            : daysUntil == 0
                                ? 'VENCE HOJE'
                                : daysUntil == 1
                                    ? 'Vence amanhã'
                                    : '$daysUntil dias restantes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Botão de deletar
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.redAccent,
                iconSize: 28,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: bgColor,
                      title: Text(
                        'Excluir Prazo',
                        style: TextStyle(color: textColor),
                      ),
                      content: Text(
                        'Deseja excluir "${deadline.title}"?',
                        style: TextStyle(color: textColor),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onDelete();
                          },
                          child: const Text(
                            'Excluir',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
