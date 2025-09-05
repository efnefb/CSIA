import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_firebase/util/task.dart';
import 'package:test_firebase/util/time_handler.dart';
import '../util/controllers.dart';
import '../manager.dart';

abstract class TaskChanges extends StatefulWidget {
  final Controllers controllers;
  final Task? calendarViewAddTask;

  TaskChanges({
    super.key,
    required this.controllers,
    this.calendarViewAddTask,
  });
}


abstract class TaskChangesState<T extends TaskChanges> extends State<T> {
  @override
  void initState() {
    super.initState();
    initializeControllers();
  }

  //These are for child classes TaskAdds and TaskEdits to implement
  void initializeControllers();
  void onSave();

  @override
  Widget build(BuildContext context) {
    List<String> categoryList = context.read<Manager>().categorySet.toList();

    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            //NAME
            TextField(
              controller: widget.controllers.nameController,
              decoration: const InputDecoration(
                labelText: 'Task name',
                border: OutlineInputBorder(),
                hintText: "Enter Task Name",
              ),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            //DESCRIPTION
            TextField(
              controller: widget.controllers.descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            //CATEGORY
            DropdownButtonFormField<String>(
              value: widget.controllers.categorySelected,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: categoryList
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => widget.controllers.categorySelected = value),
              hint: Text('Select category'),
            ),

            const SizedBox(height: 16),

            //EFFORT
            DropdownButtonFormField<String>(
              value: widget.controllers.effortSelected,
              decoration: const InputDecoration(
                labelText: 'Effort',
                border: OutlineInputBorder(),
              ),
              items: Manager.effortList
                  .map(
                    (effort) =>
                        DropdownMenuItem(value: effort, child: Text(effort)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => widget.controllers.effortSelected = value),
              hint: Text('Select effort level'),
            ),

            const SizedBox(height: 16),

            //PRIORITY
            DropdownButtonFormField<String>(
              value: widget.controllers.prioritySelected,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: Manager.priorityList
                  .map(
                    (priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => widget.controllers.prioritySelected = value),
              hint: Text('Select priority'),
            ),

            const SizedBox(height: 16),

            IconButton(
              onPressed: () async {
                final taskTimeData = widget.calendarViewAddTask != null
                    ? await TimeHandler.selectTimes(
                        context,
                        widget.calendarViewAddTask,
                      )
                    : await TimeHandler.selectTimes(context);
                widget.controllers.startTimeSelected =
                    taskTimeData['startTime'] as DateTime?;
                widget.controllers.endTimeSelected =
                    taskTimeData['endTime'] as DateTime?;
                widget.controllers.recurrenceSelected =
                    taskTimeData['recurrence'] as String?;
                widget.controllers.customRecurrenceDaysSelected =
                    taskTimeData['customRecurrenceDays'] as int?;
                widget.controllers.recurUntil =
                    taskTimeData['recurUntil'] as DateTime?;
              },
              icon: Icon(Icons.calendar_today, size: 20),
              tooltip: 'Set times',
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ),
      ),

      actions: [
        if (widget.calendarViewAddTask != null)
          IconButton(
            onPressed: () {
              Manager.showDeleteConfirmation(
                context,
                widget.calendarViewAddTask as Task,
                context.read<Manager>().deleteTask,
                onDeleteComplete: () {
                  Navigator.of(context).pop(); // Close the TaskEdits dialog after deletion
                },
              );
            },
            icon: Icon(Icons.delete, color: Colors.red),
            tooltip: "Delete Task",
          ),
        if (widget.calendarViewAddTask != null)
          IconButton(
            onPressed: () {
              context.read<Manager>().completeTask(widget.calendarViewAddTask as Task);
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.check),
            tooltip: "Complete task",
          ),

        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onSave();
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
