import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_firebase/util/task.dart';
import '../manager.dart';
import '../util/controllers.dart';
import '../util/task_changes.dart';

class TaskAdds extends TaskChanges {
  TaskAdds({
    super.key,
}) : super(controllers: Controllers());

  @override
  State<TaskAdds> createState() => _TaskAddsState();

}

class _TaskAddsState extends TaskChangesState<TaskAdds>{

  @override
  void initializeControllers(){
    widget.controllers.clearAll();
  }

  @override
  void onSave(){
    Map<String, dynamic> taskData = widget.controllers.getInputtedData();
    context.read<Manager>().addTask(
      Task.pack(taskData)
    );
    widget.controllers.clearAll();
  }
}






