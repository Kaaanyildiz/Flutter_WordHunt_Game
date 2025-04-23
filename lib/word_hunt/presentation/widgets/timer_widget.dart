import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int timeLeft;

  const TimerWidget({
    super.key,
    required this.timeLeft,
  });

  @override
  Widget build(BuildContext context) {
    // Change color based on remaining time
    final Color timerColor = timeLeft > 30
        ? Colors.green
        : timeLeft > 10
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: timerColor,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer,
            color: timerColor,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '$timeLeft',
            style: TextStyle(
              color: timerColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}