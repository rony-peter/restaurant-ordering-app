class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool isAvailable;
  final String? imageUrl;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    this.imageUrl,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: json['price'] is String
          ? double.parse(json['price'])
          : (json['price'] as num).toDouble(),
      category: json['category'] ?? 'General',
      isAvailable: json['isAvailable'] ?? true,
      imageUrl: json['imageUrl'],
    );
  }
}

class CartItem {
  final MenuItem menuItem;
  int quantity;
  String? notes;

  CartItem({required this.menuItem, this.quantity = 1, this.notes});

  double get totalPrice => menuItem.price * quantity;
}
