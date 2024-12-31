// lib/models/habit.dart

import 'package:flutter/material.dart';

class Habit {
  String name;
  TimeOfDay time;
  DateTime startDate;
  DateTime endDate;
  bool isCompleted;

  Habit({
    required this.name,
    required this.time,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
  });
}
