import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/deadline.dart';
import '../utils/app_colors.dart';

class DeadlineListItem extends StatelessWidget {
  final Deadline deadline;
  final VoidCallback onDelete;

  const DeadlineListItem({
    required this.deadline,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.yMMMd().format(deadline.date);
    return Card(
      color: Colors.white10,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Icon(Icons.calendar_month, color: AppColors.blue),
        title: Text(deadline.title, style: TextStyle(color: AppColors.onSlate)),
        subtitle: Text('${deadline.category}  $dateStr', style: TextStyle(color: AppColors.onSlate.withOpacity(0.9))),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
