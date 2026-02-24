import 'package:flutter/material.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _venueController = TextEditingController();
  final _countController = TextEditingController();
  final _scheduleController = TextEditingController();

  void _submit() {
    // TODO: Add event to Firestore
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event created successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[400]!,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                size: 40,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(label: 'Event Title', controller: _titleController),
            const SizedBox(height: 20),
            CustomTextField(label: 'Venue', controller: _venueController),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Max Participants',
                    controller: _countController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('Select'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Description',
              controller: _descController,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Schedule (comma separated)',
              controller: _scheduleController,
            ),
            const SizedBox(height: 40),
            CustomButton(text: 'Publish Event', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
