class Task {
  final String id;
  final String title;
  final String description;
  final String reward;
  final DateTime deadline;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.deadline,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    // Safely handle potential null or invalid deadline values
    final deadlineString = map['deadline'];
    final parsedDeadline = deadlineString != null && deadlineString is String
        ? DateTime.parse(deadlineString)
        : DateTime.now(); // Provide a default value if null or invalid

    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      reward: map['reward'] ?? '',
      deadline: parsedDeadline,
    );
  }
}
