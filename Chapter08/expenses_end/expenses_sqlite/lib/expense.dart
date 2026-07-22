class Expense {
  final int? id;
  final String title;
  final double amount;
  final DateTime createdAt;

  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'created_at': createdAt.toIso8601String(),
      };

  static Expense fromMap(Map<String, Object?> map) => Expense(
        id: map['id'] as int?,
        title: map['title'] as String,
        amount: (map['amount'] as num).toDouble(),
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
