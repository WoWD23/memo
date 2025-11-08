import 'package:flutter/material.dart';

/// TODO视图（打卡/待办）
class TodoView extends StatelessWidget {
  const TodoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO'),
      ),
      body: const Center(
        child: Text('TODO页面'),
      ),
    );
  }
}

