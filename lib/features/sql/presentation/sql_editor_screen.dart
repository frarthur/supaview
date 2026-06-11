import 'package:flutter/material.dart';

class SqlEditorScreen extends StatelessWidget {
  const SqlEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SQL Editor')),
      body: const Center(child: Text('SQL Editor Screen')),
    );
  }
}
