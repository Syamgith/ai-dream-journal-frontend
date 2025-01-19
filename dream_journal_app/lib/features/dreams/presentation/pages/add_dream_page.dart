import 'package:flutter/material.dart';

class AddDreamPage extends StatelessWidget {
  const AddDreamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Dream'),
      ),
      body: Center(
        child: Text('This is the Add Dream Page'),
      ),
    );
  }
}
