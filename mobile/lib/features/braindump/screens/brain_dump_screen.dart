import 'package:flutter/material.dart';

class BrainDumpScreen extends StatelessWidget {
  const BrainDumpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Brain Dump'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: const Center(child: Text('Ceritakan semua yang ada di kepala...')),
    );
  }
}
