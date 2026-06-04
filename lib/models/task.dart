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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
