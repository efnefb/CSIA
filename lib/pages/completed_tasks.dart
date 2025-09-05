import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../manager.dart';
import '../util/task_block_completed.dart';


class CompletedTasks extends StatelessWidget {
  const CompletedTasks({
    super.key,
  });



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/CSIA_background_completed_tasks.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text('Completed Tasks (${Provider.of<Manager>(context, listen: true).completedTasks.length})'),
          automaticallyImplyLeading: true,
          actions: [
            TextButton(
              onPressed: () {
                context.read<Manager>().clearAllCompleted();
              },
              child: Text(
                'Clear All',
                style: TextStyle(color: Colors.red, fontSize: 20),

              ),
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: Provider.of<Manager>(context, listen: true).completedTasks.length,
          itemBuilder: (context, index) {
            return TaskBlockCompleted(
              task: Provider.of<Manager>(context, listen: true).completedTasks[index],
            );
          },
        ),
      ),
    );
  }
}




