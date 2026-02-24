class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String venue;
  final int registeredCount;
  final int maxParticipants;
  final List<String> schedule;
  final String imageUrl;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.venue,
    required this.registeredCount,
    required this.maxParticipants,
    required this.schedule,
    required this.imageUrl,
  });
}
