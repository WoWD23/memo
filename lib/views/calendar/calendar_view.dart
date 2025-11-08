import 'package:flutter/material.dart';

/// 日历视图
class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日历'),
      ),
      body: const Center(
        child: Text('日历页面'),
      ),
    );
  }
}

