import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../manager.dart';
import '../util/task.dart';
import '../util/controllers.dart';
import '../util/task_changes.dart';

class TaskEdits extends TaskChanges {
  final Task task;
  final bool isCalendarInitialAdd;

  TaskEdits({
    super.key,
    required this.task,
    super.calendarViewAddTask,
    required this.isCalendarInitialAdd,
  }) : super(controllers: Controllers());


  @override
  State<TaskEdits> createState() => _TaskEditsState();
}

class _TaskEditsState extends TaskChangesState<TaskEdits> {
  @override
  void initializeControllers() {
    if (widget.isCalendarInitialAdd){
      widget.controllers.clearAll();
    } else {
      widget.controllers.nameController.text = widget.task.name;
      widget.controllers.descriptionController.text = widget.task.description;
      widget.controllers.categorySelected = widget.task.category;
      widget.controllers.effortSelected = widget.task.effort;
      widget.controllers.prioritySelected = widget.task.priority;
    }
  }

  @override
  void onSave() {
    print(widget.controllers.getInputtedData());

    Map<String, dynamic> taskData = widget.controllers.getInputtedData();
    context.read<Manager>().updateTask(taskData, widget.task);
    widget.controllers.clearAll();
  }
}
