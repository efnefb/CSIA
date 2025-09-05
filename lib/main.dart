import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:test_firebase/pages/categories.dart';
import 'firebase_options.dart';
import 'manager.dart';
import 'pages/dashboard.dart';
import 'pages/calendar.dart';
import 'pages/to_do_list.dart';
import '../pages/completed_tasks.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Manager manager = Manager();

  @override
  void initState(){
    super.initState();
    manager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => manager,
      child: MaterialApp(
        home: Consumer<Manager>(
          builder: (context, manager, child) {
            //Wait until data loaded
            if (manager.isLoading) {

            }

            // When loaded, open app
            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/CSIA_background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: DefaultTabController(
                length: 2,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(kToolbarHeight + 40),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 5.0),
                      ),
                      child: AppBar(
                        backgroundColor: Colors.blue[500],
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left side icons
                            Row(
                              children: [
                                Builder(
                                  builder: (context) => IconButton(
                                    icon: Icon(Icons.restore),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CompletedTasks(),
                                        ),
                                      );
                                    },
                                    tooltip: 'View Completed Tasks',
                                  ),
                                ),
                                Builder(
                                  builder: (context) => IconButton(
                                    icon: Icon(Icons.category),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Categories(),
                                        ),
                                      );
                                    },
                                    tooltip: 'View Categories',
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Here are all your tasks!',
                                  style: TextStyle(color: Colors.black87),
                                ),
                                SizedBox(width: 16),
                                Builder(
                                  builder: (context) => IconButton(
                                    icon: Icon(Icons.list),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ToDoList(),
                                        ),
                                      );
                                    },
                                    tooltip: 'View Today\'s Tasks',
                                  ),
                                ),
                              ],
                            ),

                            Builder(
                              builder: (context) => IconButton(
                                icon: Icon(Icons.timer),
                                onPressed: () {
                                  Manager.displayTimerUI(context);
                                },
                                tooltip: 'Use timer',
                              ),
                            ),
                          ],
                        ),
                        bottom: TabBar(
                          tabs: [
                            Tab(
                              icon: Tooltip(
                                message: 'Calendar page',
                                child: Icon(
                                  Icons.calendar_today,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Tab(
                              icon: Tooltip(
                                message: 'Dashboard page',
                                child: Icon(Icons.dashboard, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  body: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      Calendar(),
                      Dashboard(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}