import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../util/task.dart';
import '../util/time_handler.dart';
import '../manager.dart';

class TaskBlock extends StatefulWidget {
  Task task;
  TaskBlock({super.key, required this.task,});

  @override
  State<TaskBlock> createState() => _TaskBlockState();
}

class _TaskBlockState extends State<TaskBlock> {

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Task Name
            SizedBox(
              width: 120,
              child: Text(
                widget.task.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 12),

            // Date, Time Info
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat(
                          'MMM dd, hh:mm a',
                        ).format(widget.task.startTime),
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_filled,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat(
                          'MMM dd, hh:mm a',
                        ).format(widget.task.endTime),
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 4),

            // Category,  Priority Info
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.category, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        widget.task.category,
                        style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.flag, size: 16, color: Manager.getPriorityEffortColor(widget.task.priority)),
                      const SizedBox(width: 4),
                      Text(
                        'Priority: ${widget.task.priority}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Manager.getPriorityEffortColor(widget.task.priority),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.work, size: 16, color: Manager.getPriorityEffortColor(widget.task.effort)),
                      const SizedBox(width: 4),
                      Text(
                        'Effort: ${widget.task.effort}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Manager.getPriorityEffortColor(widget.task.effort),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Description
            if (widget.task.description.isNotEmpty)
              Expanded(
                flex: 2,
                child: Tooltip(
                  message: widget.task.description,
                  child: Text(
                    widget.task.description,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

            const SizedBox(width: 6),

            // Action Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () async {
                    final taskTimeData = await TimeHandler.selectTimes(context, widget.task);
                    context.read<Manager>().updateTaskTimes(taskTimeData, widget.task);},
                  icon: Icon(Icons.calendar_today, size: 20),
                  tooltip: 'Set times',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () => Manager.displayTaskEditsUI(context: context, task: widget.task),
                  icon: Icon(Icons.edit, size: 20),
                  tooltip: 'Edit task',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: (){Manager.showDeleteConfirmation(context, widget.task, context.read<Manager>().deleteTask);},
                  icon: Icon(Icons.delete, size: 20),
                  tooltip: 'Delete task',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () => context.read<Manager>().completeTask(widget.task),
                  icon: Icon(Icons.check, size: 20),
                  tooltip: 'Complete task',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
