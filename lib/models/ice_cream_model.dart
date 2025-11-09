import 'package:cloud_firestore/cloud_firestore.dart';

class IceCream {
  final String? id;
  final String name;
  final double price;
  final String base;
  final String authorId;
  final String authorName;
  final List<String> flavors;
  final List<String> toppings;
  final DateTime createdAt;

  IceCream({
    this.id,
    required this.name,
    required this.price,
    this.base = 'Cone',
    required this.authorId,
    required this.authorName,
    required this.flavors,
    required this.toppings,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'base': base,
      'authorId': authorId,
      'authorName': authorName,
      'flavors': flavors,
      'toppings': toppings,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory IceCream.fromMap(String id, Map<String, dynamic> map) {
    return IceCream(
      id: id,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      base: map['base'] as String? ?? 'Cone',
      authorId: map['authorId'] as String,
      authorName: map['authorName'] as String,
      flavors: List<String>.from(map['flavors']),
      toppings: List<String>.from(map['toppings']),
      createdAt: (map['createdAt'] as Timestamp).toDate()
    );
  }

  IceCream copyWith({
    String? id,
    String? name,
    double? price,
    String? base,
    String? authorId,
    String? authorName,
    List<String>? flavors,
    List<String>? toppings,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return IceCream(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      base: base ?? this.base,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      flavors: flavors ?? this.flavors,
      toppings: toppings ?? this.toppings,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}