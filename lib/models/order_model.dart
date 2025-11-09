import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String? id;
  final int orderNumber;
  final String iceCreamId;
  final String iceCreamName;
  final String customerId;
  final String customerName;
  final double total;
  final List<String> flavors;
  final List<String> toppings;
  final String status; // pending, paid, preparing, ready, delivered, cancelled
  final DateTime createdAt;

  OrderModel({
    this.id,
    required this.orderNumber,
    required this.iceCreamId,
    required this.iceCreamName,
    required this.customerId,
    required this.customerName,
    required this.total,
    required this.flavors,
    required this.toppings,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'iceCreamId': iceCreamId,
      'iceCreamName': iceCreamName,
      'customerId': customerId,
      'customerName': customerName,
      'total': total,
      'flavors': flavors,
      'toppings': toppings,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      orderNumber: map['orderNumber'] as int? ?? 0,
      iceCreamId: map['iceCreamId'] as String? ?? '',
      iceCreamName: map['iceCreamName'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      total: (map['total'] as num).toDouble(),
      flavors: List<String>.from(map['flavors'] ?? []),
      toppings: List<String>.from(map['toppings'] ?? []),
      status: map['status'] as String? ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
