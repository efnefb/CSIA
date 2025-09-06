import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../manager.dart';
import '../util/task.dart';
import '../util/controllers.dart';
import '../util/task_changes.dart';

class TaskEdits extends TaskChanges {
  final Task task;
  bool? isCalendarInitialAdd = false;

  TaskEdits({
    super.key,
    required this.task,
    super.calendarViewAddedTask,
    this.isCalendarInitialAdd,
  }) : super(controllers: Controllers());


  @override
  State<TaskEdits> createState() => _TaskEditsState();
}

class _TaskEditsState extends TaskChangesState<TaskEdits> {
  @override
  void initializeControllers() {
    if (widget.isCalendarInitialAdd == null || widget.isCalendarInitialAdd == false){
      widget.controllers.nameController.text = widget.task.name;
      widget.controllers.descriptionController.text = widget.task.description;
      widget.controllers.categorySelected = widget.task.category;
      widget.controllers.effortSelected = widget.task.effort;
      widget.controllers.prioritySelected = widget.task.priority;
    } else{
      widget.controllers.clearAll();
    }
  }

  @override
  void onSave() {
    Map<String, dynamic> taskData = widget.controllers.getInputtedData();
    context.read<Manager>().updateTask(taskData, widget.task);
    widget.controllers.clearAll();
  }
}
