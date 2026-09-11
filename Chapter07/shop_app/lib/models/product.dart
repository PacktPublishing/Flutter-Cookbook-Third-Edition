class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String emoji;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.emoji,
  });
}

final List<Product> sampleProducts = [
  Product(
    id: '1',
    name: 'Wireless Headphones',
    description:
        'Noise-cancelling over-ear headphones with 30-hour battery life.',
    price: 79.99,
    emoji: '🎧',
  ),
  Product(
    id: '2',
    name: 'Mechanical Keyboard',
    description: 'Compact 75% layout with hot-swappable switches.',
    price: 129.99,
    emoji: '⌨️',
  ),
  Product(
    id: '3',
    name: 'USB-C Hub',
    description: '7-in-1 hub with HDMI, SD card reader, and 100W passthrough.',
    price: 49.99,
    emoji: '🔌',
  ),
  Product(
    id: '4',
    name: 'Laptop Stand',
    description: 'Adjustable aluminum stand for laptops up to 17 inches.',
    price: 39.99,
    emoji: '💻',
  ),
];

Product? findProductById(String id) =>
    sampleProducts.where((p) => p.id == id).firstOrNull;
