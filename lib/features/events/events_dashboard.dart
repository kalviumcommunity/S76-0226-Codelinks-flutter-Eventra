import 'package:flutter/material.dart';
import '../../core/models/event_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/database/firestore_service.dart';
import '../../shared/widgets/event_card.dart';
import 'event_details_screen.dart';
import 'create_event_screen.dart';

class EventsDashboard extends StatefulWidget {
  const EventsDashboard({super.key});

  @override
  State<EventsDashboard> createState() => _EventsDashboardState();
}

class _EventsDashboardState extends State<EventsDashboard> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    // Role from AuthService
    final bool isAdmin = AuthService.instance.isAdmin;

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
          StreamBuilder<List<EventModel>>(
            stream: _firestoreService.getAllEvents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final events = snapshot.data ?? [];
              if (events.isEmpty) {
                return const Center(child: Text('No events found.'));
              }
              return Column(
                children: events
                    .map(
                      (event) => EventCard(
                        event: event,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailsScreen(event: event),
                            ),
                          );
                        },
                        onRegister: () async {
                          try {
                            final userId = AuthService.instance.currentUser?.id;
                            if (userId != null) {
                              await _firestoreService.registerForEvent(
                                  userId, event.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Registered successfully!')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Please login to register.')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                      ),
                    )
                    .toList(),
              );
            },
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
