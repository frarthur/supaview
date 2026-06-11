import 'package:flutter/material.dart';

class FunctionsScreen extends StatelessWidget {
  const FunctionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edge Functions')),
      body: const Center(child: Text('Functions Screen')),
    );
  }
}
