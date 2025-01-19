import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dream_entry.dart';
import '../../providers/dreams_provider.dart';

class AddDreamPage extends ConsumerWidget {
  const AddDreamPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController _descriptionController =
        TextEditingController();
    final FocusNode _descriptionFocusNode = FocusNode();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Dream'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
              decoration: InputDecoration(
                labelText: 'Dream Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            Text('Date: ${DateTime.now().toLocal().toString().split(' ')[0]}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Unfocus the TextField to avoid focus-related errors
                _descriptionFocusNode.unfocus();

                final dream = DreamEntry(
                  id: DateTime.now().toString(), // Generate a unique ID
                  title: 'Dream Title', // Placeholder for title
                  description: _descriptionController.text,
                  date: DateTime.now(),
                );
                ref.read(dreamsProvider.notifier).addDream(dream);
              },
              child: Text('Save Dream'),
            ),
          ],
        ),
      ),
    );
  }
}
