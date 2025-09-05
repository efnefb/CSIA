import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimerPopup extends StatefulWidget {
  final int hours;
  final int minutes;
  final int seconds;

  const TimerPopup({
    super.key,
    required this.hours,
    required this.minutes,
    required this.seconds
  });

  @override
  State<TimerPopup> createState() => _TimerPopupState();
}

class _TimerPopupState extends State<TimerPopup> {
  late int timeLeft;
  late int totalSeconds;
  Timer? timer;
  bool timerStarted = false;
  late TextEditingController hourController;
  late TextEditingController minuteController;
  late TextEditingController secondController;

  String completionMessage = "Time complete!";

  @override
  void initState() {
    super.initState();
    hourController = TextEditingController(text: widget.hours.toString());
    minuteController = TextEditingController(text: widget.minutes.toString());
    secondController = TextEditingController(text: widget.seconds.toString());
    totalSeconds = widget.hours * 3600 + widget.minutes * 60 + widget.seconds;
    timeLeft = totalSeconds;
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    secondController.dispose();
    timer?.cancel();
    super.dispose();
  }

  Future<void> showCompletionMessage() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      print('Sound playback failed: $e');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Timer Complete'),
          content: Text(completionMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((_) {
      Navigator.of(context).pop();
    });
  }

  void startTimer() {
    final hours = int.tryParse(hourController.text) ?? 0;
    final minutes = int.tryParse(minuteController.text) ?? 0;
    final seconds = int.tryParse(secondController.text) ?? 0;

    setState(() {
      timerStarted = true;
      totalSeconds = hours * 3600 + minutes * 60 + seconds;
      timeLeft = totalSeconds;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
        showCompletionMessage();
      }
    });
  }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Productivity Timer"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: hourController,
                  decoration: const InputDecoration(
                    labelText: 'Hours',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !timerStarted,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: minuteController,
                  decoration: const InputDecoration(
                    labelText: 'Minutes',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !timerStarted,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: secondController,
                  decoration: const InputDecoration(
                    labelText: 'Seconds',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !timerStarted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          CircularProgressIndicator(
            value: totalSeconds > 0 ? timeLeft / totalSeconds : 0,
          ),

          const SizedBox(height: 16),

          Text(
            formatTime(timeLeft),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          if (!timerStarted)
            ElevatedButton(
              onPressed: startTimer,
              child: const Text('Start Timer'),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            timer?.cancel();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}