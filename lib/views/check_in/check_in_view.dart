import 'package:flutter/material.dart';

/// 打卡视图
class CheckInView extends StatelessWidget {
  const CheckInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('打卡'),
      ),
      body: const Center(
        child: Text('打卡页面'),
      ),
    );
  }
}

