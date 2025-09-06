import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../manager.dart';
import '../util/task.dart';

class Calendar extends StatefulWidget {
  const Calendar({
    super.key,
  });

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  List<Appointment> taskListCalendar = [];
  Map<Appointment, Task> appointmentTaskMap = {};
  List<CalendarView> calendarViews = [
    CalendarView.week,
    CalendarView.month,
  ];
  int viewKey = 0;
  CalendarView currentView = CalendarView.week;


  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    loadAppointments();
  }

  void loadAppointments() {
    taskListCalendar = [];

    for (Task task in Provider.of<Manager>(context, listen: true).taskList) {
      Appointment appointment = Appointment(
          startTime: task.startTime,
          endTime: task.endTime,
          notes: task.description,
          subject: task.name,
      );
      taskListCalendar.add(appointment);
      appointmentTaskMap[appointment] = task;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Manager>(
      builder: (context, manager, child){
        loadAppointments();

        return Scaffold(
          body: CalendarWidget(
            key: ValueKey(viewKey),
            view: currentView,
            taskListCalendar: taskListCalendar,
            appointmentTaskMap: appointmentTaskMap,
          ),

          bottomNavigationBar: BottomNavigationBar(
            currentIndex: calendarViews.indexOf(currentView),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_view_week),
                label: "Week view",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_view_month),
                label: "Month view",
              ),
            ],
            onTap: (index) {
              setState(() {
                currentView = calendarViews[index];
                viewKey++;
              });
            },
          ),
        );
      }
    );
  }
}

class TaskDataSource extends CalendarDataSource {
  TaskDataSource(List<Appointment> source) {
    appointments = source;
  }
}









class CalendarWidget extends StatefulWidget {
  final CalendarView view;
  final List<Appointment> taskListCalendar;
  final Map<Appointment, Task> appointmentTaskMap;

  const CalendarWidget({
    super.key,
    required this.view,
    required this.taskListCalendar,
    required this.appointmentTaskMap,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {

  static String formatTime(DateTime time) {
    final hour = time.hour % 12;
    final hourDisplay = hour == 0 ? 12 : hour;
    final period = time.hour < 12 ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hourDisplay:$minute $period';
  }

  static String formatTimeRange(DateTime start, DateTime end) {
    if (start.day == end.day) {
      return '${formatTime(start)} - ${formatTime(end)}';
    } else {
      final daysDiff = end.difference(start).inDays;
      return '${formatTime(start)} - +$daysDiff day${daysDiff > 1 ? 's' : ''}';
    }
  }

  // For Month view - only show task name
  Widget buildMonthViewAppointment(Appointment appointment, Task? task) {
    return Center(
      child: Text(
        task?.name ?? appointment.subject,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 5,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

// Week view
  Widget buildWeekViewAppointment(Appointment appointment, Task? task, bool isShortAppointment) {
    if (isShortAppointment) {
      // Minimal display for short appointments, only name and time
      return Container(
        padding: EdgeInsets.all(1),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  task?.name ?? appointment.subject,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 1),
              Text(
                formatTimeRange(appointment.startTime, appointment.endTime),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    } else {
      // Full display for longer appointments, scrollable
      return Container(
        padding: EdgeInsets.all(1),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth - 2,
                  maxWidth: constraints.maxWidth - 2,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Task name
                    Text(
                      task?.name ?? appointment.subject,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        height: 1.0,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 1),

                    // Time range
                    Text(
                      formatTimeRange(appointment.startTime, appointment.endTime),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 2),

                    // Category and priority on same line
                    if (task?.category != null || task?.priority != null)
                      Row(
                        children: [
                          // Category
                          if (task?.category != null)
                            Expanded(
                              flex: 3,
                              child: Text(
                                task!.category,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 7, // Reduced from 8 to 7
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                  height: 1.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                          // Priority label - fixed width to prevent overflow
                          if (task?.priority != null)
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth * 0.15,
                              ),
                              margin: EdgeInsets.only(left: 1),
                              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                              decoration: BoxDecoration(
                                color: Manager.getPriorityEffortColor(task!.priority),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                task.priority[0],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 6,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),

                    // Effort level
                    if (task?.effort != null)
                      Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Text(
                          '${task!.effort} effort',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 7,
                            fontWeight: FontWeight.w600,
                            height: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // Description
                    if (task?.description.isNotEmpty == true)
                      Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Text(
                          task!.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 7,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            height: 1.0,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/CSIA_background_calendar.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: SfCalendar(
        view: widget.view,
        firstDayOfWeek: 6,
        dataSource: TaskDataSource(widget.taskListCalendar),
        showNavigationArrow: true,
        allowDragAndDrop: false,

        // week view settings
        timeSlotViewSettings: TimeSlotViewSettings(
          timeFormat: 'h a',
          timeTextStyle: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          timeInterval: Duration(minutes: 60),
          timeIntervalHeight: 60,
        ),

        viewHeaderStyle: ViewHeaderStyle(
          dayTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          dateTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        // Month view setting
        monthViewSettings: MonthViewSettings(
          showAgenda: false,
          dayFormat: 'EEE',
          showTrailingAndLeadingDates: true,
          appointmentDisplayCount: 3,
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
          monthCellStyle: MonthCellStyle(
            trailingDatesTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            leadingDatesTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            todayBackgroundColor: Colors.blue.withOpacity(0.1),
            todayTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),


        // general styling
        cellBorderColor: Colors.white,
        todayHighlightColor: Colors.blue[300],

        headerStyle: CalendarHeaderStyle(
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          backgroundColor: Colors.blue[500],
        ),

        appointmentBuilder: (context, details) {
          final Appointment appointment = details.appointments.first;
          final Task? task = widget.appointmentTaskMap[appointment];
          final duration = appointment.endTime.difference(appointment.startTime);
          final isShortAppointment = duration.inMinutes < 60;

          return Container(
            width: details.bounds.width,
            height: details.bounds.height,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            padding: EdgeInsets.all(4),
            child: widget.view == CalendarView.month
                ? buildMonthViewAppointment(appointment, task)
                : buildWeekViewAppointment(appointment, task, isShortAppointment),
          );
        },

        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.calendarCell) {
            Map<String, dynamic> newTaskData = {
              'startTime': DateTime(details.date!.year, details.date!.month, details.date!.day, details.date!.hour, details.date!.minute,
              ),
              'endTime': DateTime(details.date!.year, details.date!.month, details.date!.day, details.date!.hour + 1, details.date!.minute,
              ),
            };

            Task newTask = Task.pack(newTaskData);

            context.read<Manager>().addTask(newTask);

            Manager.displayTaskEditsUI(
              context: context,
              task: newTask,
              calendarViewAddedTask: newTask,
              isCalendarInitialAdd: true,
            );
          } else if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
            final Appointment tappedAppointment = details.appointments!.first;

            Task selectedTask = widget.appointmentTaskMap[tappedAppointment] as Task;

            Manager.displayTaskEditsUI(
              context: context,
              task: selectedTask,
              calendarViewAddedTask: selectedTask,
              isCalendarInitialAdd: false,
            );
          }
        },
      ),
    );
  }
}



