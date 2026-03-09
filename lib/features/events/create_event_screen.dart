import 'package:flutter/material.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart';
import '../../core/models/event_model.dart';
import '../../core/services/database/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/event_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _venueController = TextEditingController();
  final _countController = TextEditingController();
  final _scheduleController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _submit() async {
    if (_titleController.text.isEmpty ||
        _venueController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill required fields and select a date')),
      );
      return;
    }

    try {
      final user = AuthService.instance.currentUser;
      final scheduleList = _scheduleController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final event = EventModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        venue: _venueController.text.trim(),
        date: _selectedDate!,
        registeredCount: 0,
        maxParticipants: int.tryParse(_countController.text) ?? 0,
        schedule: scheduleList,
        imageUrl:
            'https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=2070&auto=format&fit=crop', // Default image or user provided
        organizer: user?.name ?? 'Admin',
        createdBy: user?.id ?? 'admin_id',
        createdAt: DateTime.now(),
      );

      await _firestoreService.createEvent(event);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating event: $e')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  final _imageUrlController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
      );
      setState(() {
        if (time != null) {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        } else {
          _selectedDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final venue = _venueController.text.trim();
    final countText = _countController.text.trim();
    final scheduleText = _scheduleController.text.trim();

    if (title.isEmpty || desc.isEmpty || venue.isEmpty || countText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    final maxParticipants = int.tryParse(countText);
    if (maxParticipants == null || maxParticipants <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid number for max participants')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final schedule = scheduleText.isNotEmpty
          ? scheduleText.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
          : <String>[];

      await EventService.instance.createEvent(
        title: title,
        description: desc,
        date: _selectedDate!,
        venue: venue,
        maxParticipants: maxParticipants,
        schedule: schedule,
        imageUrl: _imageUrlController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Event Banner', style: TextStyle(color: Colors.grey)),
                ],
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
                        'Date & Time',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_month),
                        label: Text(_selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Select'),
                        label: Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Select',
                        ),
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
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Image URL (optional)',
              controller: _imageUrlController,
            ),
            const SizedBox(height: 40),
            _isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(text: 'Publish Event', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
