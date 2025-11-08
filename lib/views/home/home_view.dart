import 'package:flutter/material.dart';

/// 首页视图
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
      ),
      body: const Center(
        child: Text('首页'),
      ),
    );
  }
}

