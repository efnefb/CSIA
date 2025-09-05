import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../manager.dart';
import '../util/task_block.dart';
import '../util/task.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  TextEditingController taskNameSearchController = TextEditingController();
  String? categorySearchQuery;
  String? effortSearchQuery;
  String? prioritySearchQuery;
  DateTime? upperTimeSearchQuery;
  DateTime? lowerTimeSearchQuery;
  String? currentSortOrder;

  List<Task> filteredTaskList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    taskNameSearchController.removeListener(updateFilteredTaskList);
    Provider.of<Manager>(context, listen: false).removeListener(updateFilteredTaskList);
    taskNameSearchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    Provider.of<Manager>(context, listen:false).addListener(updateFilteredTaskList);
    taskNameSearchController.addListener(updateFilteredTaskList);
    updateFilteredTaskList();
  }

  bool taskFitFilter(Task task) {
    if (taskNameSearchController.text.isNotEmpty) {
      if (!task.name.toLowerCase().startsWith(
        taskNameSearchController.text.toLowerCase(),
      )) {
        return false;
      }
    }
    if (categorySearchQuery != null) {
      if (task.category != categorySearchQuery) return false;
    }
    if (effortSearchQuery != null) {
      if (task.effort != effortSearchQuery) return false;
    }
    if (prioritySearchQuery != null) {
      if (task.priority != prioritySearchQuery) return false;
    }
    if (upperTimeSearchQuery != null) {
      if (task.startTime.isBefore(upperTimeSearchQuery!)) return false;
    }
    if (lowerTimeSearchQuery != null) {
      if (task.startTime.isAfter(lowerTimeSearchQuery!)) return false;
    }
    return true;
  }

  void updateFilteredTaskList() {
    List<Task> newFilteredTaskList = [];
    for (Task task in Provider.of<Manager>(context, listen: false).taskList) {
      if (taskFitFilter(task)) newFilteredTaskList.add(task);
    }

    if (currentSortOrder == 'ascending') {
      newFilteredTaskList = sortedFilteredTaskList(newFilteredTaskList, true);
    } else if (currentSortOrder == 'descending') {
      newFilteredTaskList = sortedFilteredTaskList(newFilteredTaskList, false);
    }

    if (mounted) {
      setState(() {
        filteredTaskList = newFilteredTaskList;
      });
    }
  }

  List<Task> sortedFilteredTaskList(List<Task> toSort, bool ascending) {
    List<Task> sortedList = List<Task>.from(toSort);

    bool isSorted = false;
    Task temp;

    while (isSorted == false) {
      isSorted = true;
      for (int i = 0; i < sortedList.length - 1; i++) {

        Duration duration = sortedList[i].endTime.difference(sortedList[i].startTime,);
        Duration durationNext = sortedList[i + 1].endTime.difference(sortedList[i + 1].startTime,);

        bool swapCondition = ascending == true
            ? duration < durationNext
            : duration > durationNext;

        if (swapCondition == true) {
          temp = sortedList[i];
          sortedList[i] = sortedList[i + 1];
          sortedList[i + 1] = temp;
          isSorted = false;
        }
      }
    }
    return sortedList;
  }

  @override
  Widget build(BuildContext context) {
    List<String> categoryList = Provider.of<Manager>(context, listen: true).categorySet.toList();

    return Consumer<Manager>(
      builder: (context, manager, child){

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              titleSpacing: 0,
              toolbarHeight: 5,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(74),
                child: Column(
                  children: [
                    // Filter controls
                    Container(
                      height: 70,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 180,
                              child: TextField(
                                controller: taskNameSearchController,
                                decoration: InputDecoration(
                                  hintText: 'Search tasks...',
                                  prefixIcon: Icon(Icons.search, size: 18),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 10,
                                  ),
                                  isDense: true,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),

                            // Category filter
                            SizedBox(
                              width: 120,
                              child: DropdownButton<String>(
                                isDense: true,
                                value: categorySearchQuery,
                                items: categoryList
                                    .map(
                                      (category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(
                                      category,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                )
                                    .toList(),
                                onChanged: (value) => setState(() {
                                  categorySearchQuery = value;
                                  updateFilteredTaskList();
                                }),
                                hint: Text(
                                  'Filter Category',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            SizedBox(width: 4),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  categorySearchQuery = null;
                                  updateFilteredTaskList();
                                });
                              },
                              icon: Icon(Icons.clear, size: 14),
                              padding: EdgeInsets.all(2),
                              constraints: BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                            SizedBox(width: 6),

                            // Effort filter
                            SizedBox(
                              width: 100,
                              child: DropdownButton<String>(
                                isDense: true,
                                value: effortSearchQuery,
                                items: Manager.effortList
                                    .map(
                                      (effort) => DropdownMenuItem(
                                    value: effort,
                                    child: Text(
                                      effort,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                )
                                    .toList(),
                                onChanged: (value) => setState(() {
                                  effortSearchQuery = value;
                                  updateFilteredTaskList();
                                }),
                                hint: Text(
                                  'Filter Effort',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            SizedBox(width: 4),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  effortSearchQuery = null;
                                  updateFilteredTaskList();
                                });
                              },
                              icon: Icon(Icons.clear, size: 14),
                              padding: EdgeInsets.all(2),
                              constraints: BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                            SizedBox(width: 6),

                            // Priority filter
                            SizedBox(
                              width: 100,
                              child: DropdownButton<String>(
                                isDense: true,
                                value: prioritySearchQuery,
                                items: Manager.priorityList
                                    .map(
                                      (priority) => DropdownMenuItem(
                                    value: priority,
                                    child: Text(
                                      priority,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                )
                                    .toList(),
                                onChanged: (value) => setState(() {
                                  prioritySearchQuery = value;
                                  updateFilteredTaskList();
                                }),
                                hint: Text(
                                  'Filter Priority',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            SizedBox(width: 4),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  prioritySearchQuery = null;
                                  updateFilteredTaskList();
                                });
                              },
                              icon: Icon(Icons.clear, size: 14),
                              padding: EdgeInsets.all(2),
                              constraints: BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                            SizedBox(width: 6),

                            // Date filters
                            TextButton(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setState(() {
                                    upperTimeSearchQuery = date;
                                    updateFilteredTaskList();
                                  });
                                }
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue[50],
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                upperTimeSearchQuery != null
                                    ? 'After\n${DateFormat('MMM dd').format(upperTimeSearchQuery!)}'
                                    : 'After',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(width: 2),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  upperTimeSearchQuery = null;
                                  updateFilteredTaskList();
                                });
                              },
                              icon: Icon(Icons.clear, size: 14),
                              padding: EdgeInsets.all(2),
                              constraints: BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                            SizedBox(width: 4),

                            TextButton(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setState(() {
                                    lowerTimeSearchQuery = date;
                                    updateFilteredTaskList();
                                  });
                                }
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue[50],
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                lowerTimeSearchQuery != null
                                    ? 'Before\n${DateFormat('MMM dd').format(lowerTimeSearchQuery!)}'
                                    : 'Before',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(width: 2),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  lowerTimeSearchQuery = null;
                                  updateFilteredTaskList();
                                });
                              },
                              icon: Icon(Icons.clear, size: 14),
                              padding: EdgeInsets.all(2),
                              constraints: BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                            SizedBox(width: 4),

                            SizedBox(
                              width: 120,
                              child: DropdownButton<String>(
                                value: currentSortOrder,
                                isDense: true,
                                items: [
                                  DropdownMenuItem(
                                    value: 'ascending',
                                    child: Text('Ascending', style: TextStyle(fontSize: 12)),
                                  ),
                                  DropdownMenuItem(
                                    value: 'descending',
                                    child: Text('Descending', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                                onChanged: (value) => setState(() {
                                  currentSortOrder = value;
                                  updateFilteredTaskList();
                                }),
                                hint: Text(
                                  'Sort by duration',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  currentSortOrder = null;
                                  updateFilteredTaskList();
                                });
                              },
                              icon: Icon(Icons.clear, size: 14),
                              padding: EdgeInsets.all(2),
                              constraints: BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                            SizedBox(width: 4),


                            // Clear Filters Button
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  size: 18,
                                  color: Colors.red[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    taskNameSearchController.clear();
                                    categorySearchQuery = null;
                                    effortSearchQuery = null;
                                    prioritySearchQuery = null;
                                    upperTimeSearchQuery = null;
                                    lowerTimeSearchQuery = null;
                                    currentSortOrder = null;

                                    updateFilteredTaskList();
                                  });
                                },
                                tooltip: 'Clear all filters',
                                padding: EdgeInsets.all(4),
                                constraints: BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                              ),
                            ),
                          ],
                        ),

                      ),
                    ),
                  ],
                ),
              ),
            ),

            body: ListView.builder(
              itemCount: filteredTaskList.length,
              itemBuilder: (context, index) {
                return TaskBlock(
                  task: filteredTaskList[index],
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => Manager.displayTaskAddsUI(context),
              tooltip: 'Add new task',
              child: Icon(Icons.add),
            ),
          ),
        );
      }
    );
  }
}
