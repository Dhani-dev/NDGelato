import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String? id;
  final int orderNumber;
  final List<Map<String, dynamic>> items; // each item: {"id", "name", "price", "quantity"}
  final String customerId;
  final String customerName;
  final double total;
  final String status; // pending, paid, preparing, ready, delivered, cancelled
  final DateTime createdAt;

  OrderModel({
    this.id,
    required this.orderNumber,
    required this.items,
    required this.customerId,
    required this.customerName,
    required this.total,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'items': items,
      'customerId': customerId,
      'customerName': customerName,
      'total': total,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      orderNumber: map['orderNumber'] as int? ?? 0,
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      total: (map['total'] as num).toDouble(),
      status: map['status'] as String? ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
