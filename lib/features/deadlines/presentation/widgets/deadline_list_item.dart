import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/deadline.dart';
import '../../../../core/utils/app_colors.dart';

class DeadlineListItem extends StatelessWidget {
  final Deadline deadline;
  final VoidCallback onDelete;

  const DeadlineListItem({Key? key, required this.deadline, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy').format(deadline.date);
    final daysUntil = deadline.date.difference(DateTime.now()).inDays;
    final isUrgent = daysUntil <= 7;
    final isPast = daysUntil < 0;
    
    IconData categoryIcon;
    switch (deadline.category) {
      case 'RG':
        categoryIcon = Icons.badge;
        break;
      case 'CNH':
        categoryIcon = Icons.directions_car;
        break;
      case 'Carteirinha':
        categoryIcon = Icons.card_membership;
        break;
      default:
        categoryIcon = Icons.description;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPast
              ? [Colors.red.withOpacity(0.2), Colors.red.withOpacity(0.1)]
              : isUrgent
                  ? [AppColors.amber.withOpacity(0.2), AppColors.amber.withOpacity(0.1)]
                  : [AppColors.blue.withOpacity(0.15), AppColors.blue.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPast
              ? Colors.red.withOpacity(0.5)
              : isUrgent
                  ? AppColors.amber.withOpacity(0.5)
                  : AppColors.blue.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ícone da categoria
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPast
                    ? Colors.red.withOpacity(0.2)
                    : isUrgent
                        ? AppColors.amber.withOpacity(0.2)
                        : AppColors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                categoryIcon,
                color: isPast
                    ? Colors.red
                    : isUrgent
                        ? AppColors.amber
                        : AppColors.blue,
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
                    style: const TextStyle(
                      color: AppColors.onSlate,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          deadline.category,
                          style: TextStyle(
                            color: AppColors.onSlate.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.onSlate.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: TextStyle(
                          color: AppColors.onSlate.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Badge de dias restantes
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPast
                          ? Colors.red
                          : isUrgent
                              ? AppColors.amber
                              : Colors.green,
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
                    backgroundColor: AppColors.slate,
                    title: const Text(
                      'Excluir Prazo',
                      style: TextStyle(color: AppColors.onSlate),
                    ),
                    content: Text(
                      'Deseja excluir "${deadline.title}"?',
                      style: const TextStyle(color: AppColors.onSlate),
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
    );
  }
}
