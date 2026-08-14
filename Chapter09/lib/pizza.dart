class Pizza {
  final int id;
  final String pizzaName;
  final String description;
  final double price;

  Pizza({
    this.id = 0,
    required this.pizzaName,
    required this.description,
    required this.price,
  });

  Pizza.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      pizzaName = json['pizzaName'],
      description = json['description'],
      price = (json['price'] as num).toDouble();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pizzaName': pizzaName,
      'description': description,
      'price': price,
    };
  }
}
