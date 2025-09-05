import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../manager.dart';
import '../util/task.dart';
import '../util/task_block_todolist.dart';


class ToDoList extends StatelessWidget {
  const ToDoList({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    List<Task> dayTasks = context.read<Manager>().taskList.where(
            (task) => task.startTime.day == DateTime.now().day
    ).toList();

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/CSIA_background_todolist.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text(
            'Here are your tasks for the day:',
            style: TextStyle(color: Colors.black87),
          ),
          automaticallyImplyLeading: true,
          elevation: 2,
        ),

        body: ListView.builder(
            itemCount: dayTasks.length,
            itemBuilder: (context, index) {
              return TaskBlockTodolist(
                task: dayTasks[index],
              );
            }
        ),


      ),
    );
  }
}





