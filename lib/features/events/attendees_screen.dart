import 'package:flutter/material.dart';

class AttendeesScreen extends StatefulWidget {
  const AttendeesScreen({super.key});

  @override
  State<AttendeesScreen> createState() => _AttendeesScreenState();
}

class _AttendeesScreenState extends State<AttendeesScreen> {
  final List<Map<String, dynamic>> _attendees = [
    {'name': 'Alex Johnson', 'dept': 'Computer Science', 'hasAttended': false},
    {'name': 'Sarah Williams', 'dept': 'Information Tech', 'hasAttended': true},
    {'name': 'Michael Chen', 'dept': 'Electronics', 'hasAttended': false},
    {'name': 'Emily Davis', 'dept': 'Civil Eng.', 'hasAttended': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendees'),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: _attendees.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final attendee = _attendees[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.withOpacity(0.1),
                child: Text(
                  attendee['name']![0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                attendee['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(attendee['dept']),
              trailing: Switch(
                value: attendee['hasAttended'],
                onChanged: (val) {
                  setState(() {
                    _attendees[index]['hasAttended'] = val;
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
