import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task.dart';

class FirestoreService{
  final CollectionReference<Map<String, dynamic>> taskListFB = FirebaseFirestore.instance.collection("taskList");
  final CollectionReference<Map<String, dynamic>> completedTaskListFB = FirebaseFirestore.instance.collection("completedTaskList");
  final CollectionReference<Map<String, dynamic>> categorySetFB = FirebaseFirestore.instance.collection("categorySet");

  void addOrUpdateTask(Task newTask) {
    taskListFB.doc(newTask.id).set(newTask.unpack());
  }


  void updateTaskTimes(Map<String, dynamic> taskTimes, Task task) {
    taskListFB.doc(task.id).update({
      'startTime': taskTimes['startTime'],
      'endTime': taskTimes['endTime'],
      'recurrence': taskTimes['recurrence'],
      'customRecurrenceDays': taskTimes['customRecurrenceDays']
    });
  }

  void deleteTask(Task task) {
    taskListFB.doc(task.id).delete();
  }

  void completeTask(Task task) {
    completedTaskListFB.doc(task.id).set(task.unpack());
    taskListFB.doc(task.id).delete();
  }

  void recoverTask(Task task) {
    taskListFB.doc(task.id).set(task.unpack());
    completedTaskListFB.doc(task.id).delete();
  }

  Future<void> clearAllCompleted() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await completedTaskListFB.get();
    for (var docSnap in querySnapshot.docs) {
      docSnap.reference.delete();
    }
  }

  void updateCategories(Set<String> categorySetFrontEnd) {
    categorySetFB.doc('categorySet').set({
      'categorySetItems': categorySetFrontEnd.toList()
    });
  }

  String generateNewId() {
    return taskListFB.doc().id;
  }

  Future<List<Task>> readListFromBackEnd(CollectionReference<Map<String, dynamic>> collectionReference) async {
    List<Task> listToFrontEnd = [];
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await collectionReference.get();

    for (var docSnap in querySnapshot.docs) {
      final Map<String, dynamic>? data = docSnap.data();
      if (data != null) {
        listToFrontEnd.add(Task.pack(data));
      }
    }

    return listToFrontEnd;
  }

  Future<List<Task>> readTaskList() {
    return readListFromBackEnd(taskListFB);
  }

  Future<List<Task>> readCompletedTaskList() {
    return readListFromBackEnd(completedTaskListFB);
  }

  Future<Set<String>> readCategorySet() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await categorySetFB.doc('categorySet').get();

    if (!snapshot.exists) {
      return <String>{};
    }

    final Map<String, dynamic>? data = snapshot.data();
    if (data == null) {
      return <String>{};
    }

    final dynamic categoryData = data['categorySetItems'];
    if (categoryData is! List<dynamic>) {
      return <String>{};
    }

    return categoryData.cast<String>().toSet();
  }


  static DateTime? convertFirestoreDate(dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) {
      return date.toDate();
    }
    if (date is DateTime) {
      return date;
    }
    return null;
  }
}