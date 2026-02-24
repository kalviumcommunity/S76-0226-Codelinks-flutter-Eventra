import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final List<Map<String, dynamic>> _announcements = [
    {
      'title': 'New Workshop Added!',
      'message':
          'A Flutter Advanced workshop has been added to the Tech Symposium list.',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'title': 'Venue Change',
      'message':
          'The Cultural Night will now be held at the Main Auditorium instead of the OAT.',
      'date': DateTime.now().subtract(const Duration(days: 1)),
    },
  ];

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Announcement'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: 'Title')),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: 'Message'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = true;

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _announcements.length,
        itemBuilder: (context, index) {
          final ann = _announcements[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ann['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd').format(ann['date']),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ann['message'],
                    style: TextStyle(color: Colors.grey[800], height: 1.4),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _showCreateDialog,
              child: const Icon(Icons.campaign),
            )
          : null,
    );
  }
}
