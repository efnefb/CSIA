import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

class Task {
  String id;
  String name;
  String description;
  String category;
  String effort;
  String priority;
  bool isCompleted = false;
  DateTime startTime;
  DateTime endTime;
  String recurrence;
  int customRecurrenceDays;

  static Map<String, dynamic> defaultValuesMap = {
    "name": "New Task",
    "description": "This is a new task",
    "category": "School",
    "effort": "Mid",
    "priority": "Mid",
    "isCompleted":false,
    "startTime": DateTime.now(),
    'endTime':DateTime.now().add(const Duration(hours: 1)),
    "recurrence": "none",
    'customRecurrenceDays': 0,
  };

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.effort,
    required this.priority,
    required this.isCompleted,
    required this.startTime,
    required this.endTime,
    required this.recurrence,
    required this.customRecurrenceDays,
  });


  factory Task.pack(Map<String, dynamic> data) {
    return Task(
      id: data["id"] ?? "",
      name: data['name']?.toString().isNotEmpty == true
          ? data['name'] as String
          : defaultValuesMap['name'] as String,
      description: data['description']?.toString().isNotEmpty == true
          ? data['description'] as String
          : defaultValuesMap['description'] as String,
      category: data['category']?.toString().isNotEmpty == true
          ? data['category'] as String
          : defaultValuesMap['category'] as String,
      effort: data['effort']?.toString().isNotEmpty == true
          ? data['effort'] as String
          : defaultValuesMap['effort'] as String,
      priority: data['priority']?.toString().isNotEmpty == true
          ? data['priority'] as String
          : defaultValuesMap['priority'] as String,
      isCompleted: data['isCompleted'] as bool? ?? defaultValuesMap['isCompleted'] as bool,

      startTime: FirestoreService.convertFirestoreDate(data['startTime']) ?? defaultValuesMap['startTime'] as DateTime,
      endTime: FirestoreService.convertFirestoreDate(data['endTime']) ?? defaultValuesMap['endTime'] as DateTime,

      recurrence: data['recurrence']?.toString().isNotEmpty == true
          ? data['recurrence'] as String
          : defaultValuesMap['recurrence'] as String,
      customRecurrenceDays: data['customRecurrenceDays'] as int? ?? defaultValuesMap['customRecurrenceDays'] as int,
    );
  }


  Map<String, dynamic> unpack(){
    return {
      "id": id,
      "name": name,
      "description": description,
      "category": category,
      "effort":effort,
      "priority":priority,
      "isCompleted":isCompleted,
      "startTime":Timestamp.fromDate(startTime),
      'endTime':Timestamp.fromDate(endTime),
      "recurrence": recurrence,
      'customRecurrenceDays': customRecurrenceDays,
    };
  }

  @override
  String toString() {
    return 'Task{id: $id, name: $name, description: $description, category: $category, effort: $effort, priority: $priority, isCompleted: $isCompleted, startTime: $startTime, endTime: $endTime, recurrence: $recurrence, customRecurrenceDays: $customRecurrenceDays}';
  }
}
