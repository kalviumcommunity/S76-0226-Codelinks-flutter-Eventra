import 'package:flutter/material.dart';
import '../../core/models/event_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/event_service.dart';
import '../../shared/widgets/custom_button.dart';
import 'attendees_screen.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatelessWidget {
  final EventModel event;

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late bool _isRegistered;

  @override
  void initState() {
    super.initState();
    final userId = AuthService.instance.currentUser?.id ?? '';
    _isRegistered = widget.event.registeredUsers.contains(userId);
  }

  Future<void> _toggleRegistration() async {
    final userId = AuthService.instance.currentUser?.id ?? 'anon';
    try {
      if (_isRegistered) {
        await EventService.instance.unregisterFromEvent(widget.event.id, userId);
        if (!mounted) return;
        setState(() => _isRegistered = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration cancelled')),
        );
      } else {
        await EventService.instance.registerForEvent(widget.event.id, userId);
        if (!mounted) return;
        setState(() => _isRegistered = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered successfully!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _cancelEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Event'),
        content: const Text('Are you sure you want to cancel this event? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await EventService.instance.deleteEvent(widget.event.id);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event cancelled')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = AuthService.instance.isAdmin;
    final event = widget.event;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(event.imageUrl, fit: BoxFit.cover),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isAdmin)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {},
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoTile(
                    icon: Icons.calendar_today_outlined,
                    title: DateFormat('EEEE, MMMM dd, yyyy').format(event.date),
                    subtitle: DateFormat('hh:mm a').format(event.date),
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.location_on_outlined,
                    title: event.venue,
                    subtitle: 'College Campus',
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.people_outline,
                    title:
                        '${event.registeredCount} / ${event.maxParticipants} Joined',
                    subtitle: event.registeredCount >= event.maxParticipants
                        ? 'Event is full'
                        : 'Slots available',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'About Event',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  if (event.schedule.isNotEmpty) ...[
                    const Text(
                      'Schedule',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...event.schedule.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: Colors.indigo,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'View Attendees',
                          color: Colors.black,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AttendeesScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!isAdmin)
                    CustomButton(
                      text: _isRegistered ? 'Cancel Registration' : 'Register Now',
                      color: _isRegistered ? Colors.red : null,
                      onPressed: _toggleRegistration,
                    ),
                  if (isAdmin)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _cancelEvent,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Cancel Event'),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.indigo, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
