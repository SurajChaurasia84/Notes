class Task {
  final String id;
  String title;
  bool isCompleted;
  DateTime timestamp;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.timestamp,
  });
}
