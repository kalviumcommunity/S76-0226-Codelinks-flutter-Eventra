import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/announcement_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/announcement_model.dart';
import '../../core/services/database/firestore_service.dart';
import '../../core/services/announcement_service.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  void _showCreateDialog() {
    _titleController.clear();
    _messageController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Message'),
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
            onPressed: () async {
              if (_titleController.text.isNotEmpty &&
                  _messageController.text.isNotEmpty) {
                final announcement = AnnouncementModel(
                  id: '',
                  title: _titleController.text.trim(),
                  message: _messageController.text.trim(),
                  createdAt: DateTime.now(),
                );

                try {
                  await _firestoreService.createAnnouncement(announcement);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Announcement posted successfully!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding announcement: $e')),
                    );
                  }
                }
              }

            onPressed: () {
              final title = _titleController.text.trim();
              final message = _messageController.text.trim();
              if (title.isEmpty || message.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }
              AnnouncementService.instance.addAnnouncement(
                title: title,
                message: message,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Announcement posted!')),
              );
              setState(() {}); // Refresh local view
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = AuthService.instance.isAdmin;

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: StreamBuilder<List<AnnouncementModel>>(
        stream: _firestoreService.getAnnouncements(),
      body: StreamBuilder<List<Announcement>>(
        stream: AnnouncementService.instance.getAnnouncementsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }


          final announcements = snapshot.data ?? [];

          if (announcements.isEmpty) {
            return const Center(child: Text('No announcements yet.'));
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No announcements yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final ann = announcements[index];
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
                          Expanded(
                            child: Text(
                              ann.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd').format(ann.createdAt),

                            DateFormat('MMM dd').format(ann.date),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ann.message,
                        style: TextStyle(color: Colors.grey[800], height: 1.4),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 20),
                            onPressed: () {
                              AnnouncementService.instance
                                  .deleteAnnouncement(ann.id);
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
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
