class Expense {
  final int? key;
  final String title;
  final double amount;
  final DateTime createdAt;

  const Expense({
    this.key,
    required this.title,
    required this.amount,
    required this.createdAt,
  });

  Expense copyWith({
    int? key,
    String? title,
    double? amount,
    DateTime? createdAt,
  }) {
    return Expense(
      key: key ?? this.key,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'title': title,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(
    Map<String, Object?> map, {
    required int key,
  }) {
    return Expense(
      key: key,
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}