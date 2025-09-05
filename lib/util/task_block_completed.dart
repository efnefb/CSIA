import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../manager.dart';
import '../util/task.dart';

class TaskBlockCompleted extends StatelessWidget {
  //Attributes
  Task task;

  //Methods
  TaskBlockCompleted({
    super.key,
    required this.task,
  });


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Name
                  Text(
                    task.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Category, Effort, Priority
                  Text(
                    'Category: ${task.category} \nEffort: ${task.effort} \nPriority: ${task.priority}',
                    style: const TextStyle(fontSize: 14),
                  ),

                  // Description
                  if (task.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        task.description,
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            TextButton(
              onPressed: () => context.read<Manager>().recoverTask(task),
              child: Text("Recover"),
            ),

            IconButton(
                onPressed: () => Manager.showDeleteConfirmation(context, task, context.read<Manager>().deleteTask),
                icon: Icon(Icons.delete)
            )
          ],
        ),
      ),
    );
  }


}

