class Receipt {
  final String date;
  final List<ReceiptItem> items;
  final double total;

  Receipt({
    required this.date,
    required this.items,
    required this.total,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      date: json['date'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => ReceiptItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
    );
  }
}

class ReceiptItem {
  final String name;
  final double quantity;
  final double unitPrice;
  final double total;

  ReceiptItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }
}