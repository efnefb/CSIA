import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_firebase/util/task.dart';

class TimeHandler {
  static String getRecurrencePreview(
    String recurrence,
    int customDays,
    DateTime baseDate,
  ) {
    switch (recurrence) {
      case 'daily':
        return 'Repeats daily starting ${DateFormat('MMM dd').format(baseDate)}';
      case 'weekly':
        return 'Repeats weekly on ${DateFormat('EEEE').format(baseDate)}s';
      case 'monthly':
        return 'Repeats monthly on the ${baseDate.day}${getDaySuffix(baseDate.day)}';
      case 'custom':
        return 'Repeats every $customDays days';
      default:
        return '';
    }
  }

  static String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  static String formatDuration(Duration duration, bool isValid) {
    if (!isValid) return 'Invalid time range';

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    List<String> parts = [];
    if (days > 0) parts.add('$days day${days > 1 ? 's' : ''}');
    if (hours > 0) parts.add('$hours hour${hours > 1 ? 's' : ''}');
    if (minutes > 0) parts.add('$minutes minute${minutes > 1 ? 's' : ''}');

    return 'Duration: ${parts.join(', ')}';
  }

  static Future<Map<String, Object>> selectTimes(BuildContext context, [Task? task,]) async {

    DateTime selectedBaseDate = DateTime.now();

    // Handle base date selection
    if (task?.startTime != null) {
      selectedBaseDate = DateTime(
        task!.startTime.year,
        task.startTime.month,
        task.startTime.day,
      );
    } else {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (pickedDate != null) {
        selectedBaseDate = pickedDate;
      }
    }

    final inputtedData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        TimeOfDay initialStartTime;
        TimeOfDay initialEndTime;

        if (task != null) {
          initialStartTime = TimeOfDay(
            hour: task.startTime.hour,
            minute: task.startTime.minute,
          );
          initialEndTime = TimeOfDay(
            hour: task.endTime.hour,
            minute: task.endTime.minute,
          );
        } else {
          final now = TimeOfDay.now();
          initialStartTime = now;
          initialEndTime = TimeOfDay(hour: now.hour + 1, minute: now.minute);
        }

        TimeOfDay startTime = initialStartTime;
        TimeOfDay endTime = initialEndTime;
        int dayOffset = 0;
        String recurrence = 'none';
        int customRecurrenceDays = 1;
        DateTime? recurUntil = selectedBaseDate.add(const Duration(days: 30));
        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setState) {
            final startDateTime = DateTime(
              selectedBaseDate.year,
              selectedBaseDate.month,
              selectedBaseDate.day,
              startTime.hour,
              startTime.minute,
            );

            final endDateTime = DateTime(
              selectedBaseDate.year,
              selectedBaseDate.month,
              selectedBaseDate.day + dayOffset,
              endTime.hour,
              endTime.minute,
            );

            final isValid = endDateTime.isAfter(startDateTime);
            final duration = endDateTime.difference(startDateTime);

            return AlertDialog(
              title: const Text('Select Task Times'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Date: ${DateFormat('MMM dd, yyyy').format(selectedBaseDate)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    ListTile(
                      title: const Text('Start Time'),
                      trailing: Text(startTime.format(context)),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                        );
                        if (time != null) {
                          setState(() {
                            startTime = time;
                            errorMessage = null;
                          });
                          if (!isValid) {
                            setState(() {
                              endTime = TimeOfDay(
                                hour: startTime.hour + 1,
                                minute: startTime.minute,
                              );
                            });
                          }
                          dayOffset = 0;
                        }
                      },
                    ),

                    ListTile(
                      title: const Text('End Time'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (dayOffset > 0)
                            Text(
                              '+$dayOffset day${dayOffset > 1 ? 's' : ''} ',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          Text(endTime.format(context)),
                        ],
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: endTime,
                        );
                        if (time != null) {
                          setState(() {
                            endTime = time;
                            errorMessage = null;
                          });
                        }
                      },
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('End on: '),
                        DropdownButton<int>(
                          value: dayOffset,
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('Same day')),
                            DropdownMenuItem(value: 1, child: Text('Next day')),
                            DropdownMenuItem(value: 2, child: Text('+2 days')),
                            DropdownMenuItem(value: 3, child: Text('+3 days')),
                            DropdownMenuItem(value: 7, child: Text('+1 week')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              dayOffset = value!;
                              errorMessage = null;
                            });
                          },
                        ),
                      ],
                    ),
                    const Divider(),

                    const Text(
                      'Recurrence:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    DropdownButton<String>(
                      value: recurrence,
                      items: const [
                        DropdownMenuItem(
                          value: 'none',
                          child: Text('No recurrence'),
                        ),
                        DropdownMenuItem(value: 'daily', child: Text('Daily')),
                        DropdownMenuItem(
                          value: 'weekly',
                          child: Text('Weekly'),
                        ),
                        DropdownMenuItem(
                          value: 'monthly',
                          child: Text('Monthly'),
                        ),
                        DropdownMenuItem(
                          value: 'custom',
                          child: Text('Custom'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          recurrence = value!;
                        });
                      },
                    ),

                    if (recurrence == 'custom')
                      Column(
                        children: [
                          const SizedBox(height: 8),
                          const Text('Repeat every:'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: customRecurrenceDays > 1
                                    ? () {
                                        setState(() => customRecurrenceDays--);
                                      }
                                    : null,
                              ),
                              Text('$customRecurrenceDays days'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() => customRecurrenceDays++);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                    if (recurrence != 'none')
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          ListTile(
                            title: const Text('Repeat Until'),
                            subtitle: Text(
                              DateFormat('MMM dd, yyyy').format(recurUntil!),
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              final untilDate = await showDatePicker(
                                context: context,
                                initialDate: recurUntil,
                                firstDate: selectedBaseDate,
                                lastDate: DateTime(2100),
                              );
                              if (untilDate != null) {
                                setState(() {
                                  recurUntil = untilDate;
                                });
                              }
                            },
                          ),
                          const Divider(),
                        ],
                      ),

                    if (errorMessage != null)
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        formatDuration(duration, isValid),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isValid ? Colors.blue[700] : Colors.red,
                        ),
                      ),
                    ),

                    Text(
                      'Start: ${DateFormat('MMM dd, hh:mm a').format(startDateTime)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      'End: ${DateFormat('MMM dd, hh:mm a').format(endDateTime)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),

                    if (recurrence != 'none')
                      Text(
                        getRecurrencePreview(
                          recurrence,
                          customRecurrenceDays,
                          selectedBaseDate,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isValid
                      ? () {
                          Navigator.pop(context, {
                            'start': startTime,
                            'end': endTime,
                            'dayOffset': dayOffset,
                            'baseDate': selectedBaseDate,
                            'recurrence': recurrence,
                            'customRecurrenceDays': customRecurrenceDays,
                            'recurUntil': recurUntil,
                          });
                        }
                      : null,
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (inputtedData != null) {
      final DateTime baseDate = inputtedData['baseDate'] as DateTime;
      final TimeOfDay startTime = inputtedData['start'] as TimeOfDay;
      final TimeOfDay endTime = inputtedData['end'] as TimeOfDay;
      final int dayOffset = inputtedData['dayOffset'] as int;

      final DateTime startDateTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        startTime.hour,
        startTime.minute,
      );

      final DateTime endDateTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day + dayOffset,
        endTime.hour,
        endTime.minute,
      );

      final String recurrence = inputtedData['recurrence'] as String;
      if (recurrence == 'none') {
        return {
          'startTime': startDateTime,
          'endTime': endDateTime,
          'recurrence': recurrence,
          'customRecurrenceDays': 0,
          'recurUntil': DateTime.now(),
        };
      }

      final int customRecurrenceDays =
          inputtedData['customRecurrenceDays'] as int;
      final DateTime recurUntil = inputtedData['recurUntil'] as DateTime;

      return {
        'startTime': startDateTime,
        'endTime': endDateTime,
        'recurrence': recurrence,
        'customRecurrenceDays': customRecurrenceDays,
        'recurUntil': recurUntil,
      };
    } else {
      throw Exception('No time data selected');
    }
  }
}
