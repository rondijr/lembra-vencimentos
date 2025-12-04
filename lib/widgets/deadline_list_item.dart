import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/deadline.dart';
import '../utils/app_colors.dart';

class DeadlineListItem extends StatelessWidget {
  final Deadline deadline;
  final VoidCallback onDelete;

  const DeadlineListItem({Key? key, required this.deadline, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.yMMMd().format(deadline.date);
    return Card(
      color: Colors.white10,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.calendar_month, color: AppColors.blue),
        title: Text(deadline.title, style: const TextStyle(color: AppColors.onSlate)),
        subtitle: Text('${deadline.category}  $dateStr', style: const TextStyle(color: Color.fromRGBO(255,255,255,0.9))),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
