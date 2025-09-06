import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../util/task.dart';
import '../util/time_handler.dart';
import '../manager.dart';

class TaskBlockTodolist extends StatefulWidget {
  Task task;
  TaskBlockTodolist({super.key, required this.task,});

  @override
  State<TaskBlockTodolist> createState() => _TaskBlockTodolistState();
}

class _TaskBlockTodolistState extends State<TaskBlockTodolist> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.task.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.orangeAccent
              ),
            ),

            const SizedBox(height: 8),

            // Time info as bullet points
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.white),
                const SizedBox(width: 8),

                // Time details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Starts: ${DateFormat('EEE, MMM dd • hh:mm a').format(widget.task.startTime)}',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ends: ${DateFormat('EEE, MMM dd • hh:mm a').format(widget.task.endTime)}',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),


            // Category, Priority, Effort
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                // Category chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.category, size: 14, color: Colors.blue[700]),
                      const SizedBox(width: 4),
                      Text(
                        widget.task.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Priority
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Manager.getPriorityEffortColor(widget.task.priority).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag, size: 14, color: Manager.getPriorityEffortColor(widget.task.priority)),
                      const SizedBox(width: 4),
                      Text(
                        widget.task.priority,
                        style: TextStyle(
                          fontSize: 12,
                          color: Manager.getPriorityEffortColor(widget.task.priority),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Effort
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Manager.getPriorityEffortColor(widget.task.effort).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag, size: 14, color: Manager.getPriorityEffortColor(widget.task.effort)),
                      const SizedBox(width: 4),
                      Text(
                        widget.task.effort,
                        style: TextStyle(
                          fontSize: 12,
                          color: Manager.getPriorityEffortColor(widget.task.effort),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),


            // Description
            if (widget.task.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),

                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6), // Dark overlay
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.task.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),


                  ),
                ),
              ),

            SizedBox(height: 20),

            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () async {
                    final taskTimeData = await TimeHandler.selectTimes(
                        context, widget.task
                    );
                    context.read<Manager>().updateTaskTimes(taskTimeData, widget.task);
                  },
                  icon: Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                  tooltip: 'Set times',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () => Manager.displayTaskEditsUI(context: context, task: widget.task),
                  icon: Icon(Icons.edit, size: 20, color: Colors.blue),
                  tooltip: 'Edit task',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: (){
                    Manager.showDeleteConfirmation(context, widget.task, context.read<Manager>().deleteTask);
                  },
                  icon: Icon(Icons.delete, size: 20, color: Colors.blue),
                  tooltip: 'Delete task',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () => context.read<Manager>().completeTask(widget.task),
                  icon: Icon(Icons.check, size: 20, color: Colors.blue),
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

