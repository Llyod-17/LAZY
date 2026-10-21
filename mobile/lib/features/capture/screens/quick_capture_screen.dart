import 'package:flutter/material.dart';

class QuickCaptureScreen extends StatelessWidget {
  const QuickCaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Capture'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: const Center(child: Text('Tulis atau rekam...')),
    );
  }
}
