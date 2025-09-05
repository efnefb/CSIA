import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test_firebase/pages/timer_popup.dart';
import 'package:test_firebase/util/firestore_service.dart';
import 'package:test_firebase/util/task.dart';
import 'package:test_firebase/util/task_adds.dart';
import 'package:test_firebase/util/task_edits.dart';

class Manager extends ChangeNotifier{
  static final Manager _instance = Manager._internal();
  factory Manager() => _instance;
  Manager._internal();

  List<Task> taskList = [];
  List<Task> completedTasks = [];
  Set<String> categorySet = {};

  static final List<String> effortList = List.unmodifiable(['Low', 'Mid', 'High']);
  static final List<String> priorityList = List.unmodifiable(['Low', 'Mid', 'High']);

  bool isLoading = true;
  final firestoreSerivce = FirestoreService();

  Future<void> initialize() async{
    await loadTasksAndCategories();
  }

  Future<void> loadTasksAndCategories() async {
    setLoading(true);
    taskList = await firestoreSerivce.readTaskList();
    completedTasks = await firestoreSerivce.readCompletedTaskList();
    categorySet = await firestoreSerivce.readCategorySet();
    setLoading(false);
  }

  void setLoading(bool loading){
    isLoading = loading;
    notifyListeners();
  }


  //CRUD Methods
  void addTask(Task newTask) {
    newTask.id = firestoreSerivce.generateNewId();
    if (!taskList.contains(newTask)) taskList.insert(0, newTask);

    notifyListeners();
    firestoreSerivce.addOrUpdateTask(newTask);
  }

  void updateTask(Map<String, dynamic> newTaskData, Task task) {
    Map<String, dynamic> newTaskData1 = newTaskData;
    if (newTaskData['startTime'] == Task.defaultValuesMap['startTime'] || newTaskData['endTime'] == Task.defaultValuesMap['endTime']) {
      newTaskData1['startTime'] = task.startTime;
      newTaskData1['endTime'] = task.endTime;
    } else {
      newTaskData1 = newTaskData;
    }

    Task newTask = Task.pack(newTaskData1);
    newTask.id = task.id;

    for (int i = 0; i < taskList.length; i++) {
      if (taskList[i] == task) taskList[i] = newTask;
    }

    firestoreSerivce.addOrUpdateTask(newTask);
    notifyListeners();
  }

  void updateTaskTimes(Map<String, dynamic> taskTimes, Task task) {
    for (int i = 0; i < taskList.length; i++) {
      if (taskList[i] == task) {
        taskList[i].startTime = taskTimes['startTime'] as DateTime;
        taskList[i].endTime = taskTimes['endTime'] as DateTime;
        taskList[i].recurrence = taskTimes['recurrence'] as String;
        taskList[i].customRecurrenceDays =
        taskTimes['customRecurrenceDays'] as int;
      }
    }

    notifyListeners();
    firestoreSerivce.updateTaskTimes(taskTimes, task);
  }

  void deleteTask(Task task) {
    if (taskList.contains(task)) taskList.remove(task);
    if (completedTasks.contains(task)) completedTasks.remove(task);

    notifyListeners();
    firestoreSerivce.deleteTask(task);
  }

  void completeTask(Task task) {
    completedTasks.insert(0, task);
    taskList.remove(task);
    task.isCompleted = true;

    notifyListeners();
    firestoreSerivce.completeTask(task);
  }

  void recoverTask(Task task) {
    if (completedTasks.contains(task)) completedTasks.remove(task);
    if (!taskList.contains(task)) taskList.insert(0, task);
    task.isCompleted = false;

    notifyListeners();
    firestoreSerivce.recoverTask(task);
  }

  void clearAllCompleted() {
    completedTasks.clear();

    notifyListeners();
    firestoreSerivce.clearAllCompleted();
  }

  void addCategory(String category) {
    categorySet.add(category);

    notifyListeners();
    firestoreSerivce.updateCategories(categorySet);
  }

  void deleteCategory(String category){
    categorySet.remove(category);

    notifyListeners();
    firestoreSerivce.updateCategories(categorySet);
  }





  static void showDeleteConfirmation(
      BuildContext context,
      Task task,
      void Function(Task) deleteTask, {VoidCallback? onDeleteComplete,}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${task.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deleteTask(task);
              Navigator.pop(context); // Close delete confirmation
              //onDeleteComplete?.call(); // Call callback if provided
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static void displayTaskAddsUI(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return TaskAdds();
      },
    );
  }

  static void displayTaskEditsUI(
    BuildContext context,
    Task task,
    bool isCalendarInitialAdd,
    [Task? calendarViewAddTask]) {
    showDialog(
      context: context,
      builder: (context) {
        return TaskEdits(
          task: task,
          calendarViewAddTask: calendarViewAddTask,
          isCalendarInitialAdd: isCalendarInitialAdd,
        );
      },
    );
  }

  static void displayTimerUI(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return TimerPopup(hours: 1, minutes: 0, seconds: 0);
      },
    );
  }

  static Color getPriorityEffortColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return Colors.red[700]!;
      case 'mid': return Colors.yellow[700]!;
      case 'low': return Colors.green[700]!;
      default: return Colors.grey[700]!;
    }
  }


}



