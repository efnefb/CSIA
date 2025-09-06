import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../manager.dart';
import '../util/task.dart';
import '../util/controllers.dart';
import '../util/task_changes.dart';

class TaskEdits extends TaskChanges {
  bool? isCalendarInitialAdd;

  TaskEdits({
    super.key,
    super.task,
    super.calendarViewAddedTask,
    this.isCalendarInitialAdd = false,
  }) : super(controllers: Controllers());


  @override
  State<TaskEdits> createState() => _TaskEditsState();
}

class _TaskEditsState extends TaskChangesState<TaskEdits> {
  @override
  void initializeControllers() {
    //Task edited from Dashboard -- fields in dialog box pre-filled with that task's data
    if (widget.isCalendarInitialAdd == null || widget.isCalendarInitialAdd == false){
      widget.controllers.nameController.text = widget.task!.name;
      widget.controllers.descriptionController.text = widget.task!.description;
      widget.controllers.categorySelected = widget.task?.category;
      widget.controllers.effortSelected = widget.task?.effort;
      widget.controllers.prioritySelected = widget.task?.priority;
    } else {
      //Task added from calendar -- from user pov it is actually adding task not edit, so fields in dialog box not prefilled
      widget.controllers.clearAll();
    }
    //In both cases startTime and endTime are pre-filled with the task's start
    //and end times, because: if user is editing, times need to be filled anyway; if the user is adding from calendar, times are already implicitly set by user.
    widget.controllers.startTimeSelected = widget.task?.startTime;
    widget.controllers.endTimeSelected = widget.task?.endTime;
  }

  @override
  void onSave() {
    if (widget.task != null){
      Task task = widget.task as Task;
      Map<String, dynamic> taskData = widget.controllers.getInputtedData();
      context.read<Manager>().updateTask(taskData, task);
      widget.controllers.clearAll();
    }
  }
}


