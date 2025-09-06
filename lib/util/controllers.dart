import 'package:flutter/material.dart';
import 'package:test_firebase/util/task.dart';


class Controllers {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? categorySelected;
  String? effortSelected;
  String? prioritySelected;
  DateTime? startTimeSelected;
  DateTime? endTimeSelected;

  void disposeAll(){
    nameController.dispose();
    descriptionController.dispose();
  }

  void clearAll(){
    nameController.clear();
    descriptionController.clear();
    categorySelected = null;
    effortSelected = null;
    prioritySelected = null;
    startTimeSelected = null;
    endTimeSelected = null;
  }


  Map<String, dynamic> getInputtedData(){
    return {
      'name': nameController.text,
      'description': descriptionController.text,
      'category': categorySelected,
      'effort': effortSelected,
      'priority': prioritySelected,
      'startTime': startTimeSelected,
      'endTime': endTimeSelected
    };
  }
}

