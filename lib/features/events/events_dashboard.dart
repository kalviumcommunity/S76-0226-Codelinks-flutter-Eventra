import 'package:flutter/material.dart';
import '../../core/models/event_model.dart';
import '../../shared/widgets/event_card.dart';
import 'event_details_screen.dart';
import 'create_event_screen.dart';

class EventsDashboard extends StatefulWidget {
  const EventsDashboard({super.key});

  @override
  State<EventsDashboard> createState() => _EventsDashboardState();
}

class _EventsDashboardState extends State<EventsDashboard> {
  // Mock data - In a real app, this would come from a service/repository
  final List<Event> _events = [
    Event(
      id: '1',
      title: 'Tech Symposium 2026',
      description:
          'Annual technology symposium featuring guest speakers from top tech firms.',
      date: DateTime.now().add(const Duration(days: 5)),
      venue: 'Main Auditorium',
      registeredCount: 45,
      maxParticipants: 100,
      schedule: [
        '9:00 AM - Keynote',
        '11:00 AM - Panel Discussion',
        '2:00 PM - Workshops',
      ],
      imageUrl:
          'https://plus.unsplash.com/premium_photo-1771645903251-eba25bb877c2?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHwzNHx8fGVufDB8fHx8fA%3D%3D',
    ),
    Event(
      id: '2',
      title: 'Cultural Night',
      description:
          'A night of music, dance, and cultural performances by our students.',
      date: DateTime.now().add(const Duration(days: 12)),
      venue: 'Open Air Theatre',
      registeredCount: 120,
      maxParticipants: 200,
      schedule: [
        '6:00 PM - Folk Dance',
        '7:30 PM - Music Band',
        '9:00 PM - Dinner',
      ],
      imageUrl:
          'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=2070&auto=format&fit=crop',
    ),
        Event(
      id: '3',
      title: 'Tech night',
      description:
          'A night of music, dance, and cultural performances by our students.',
      date: DateTime.now().add(const Duration(days: 12)),
      venue: 'Open Air Theatre',
      registeredCount: 120,
      maxParticipants: 200,
      schedule: [
        '6:00 PM - Folk Dance',
        '7:30 PM - Music Band',
        '9:00 PM - Dinner',
      ],
      imageUrl:
          'https://images.unsplash.com/photo-1733241317703-7f51a0aa90cf?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: Determine if user is admin (mocking as true for now to show FAB)
    bool isAdmin = true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Events'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Featured Events',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // TODO: Replace dummy data with Firestore stream
          ..._events.map(
            (event) => EventCard(
              event: event,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailsScreen(event: event),
                  ),
                );
              },
              onRegister: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registered successfully!')),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEventScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Host Event'),
            )
          : null,
    );
  }
}
