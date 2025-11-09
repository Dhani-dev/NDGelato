import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'orders';

  // Stream all orders (admin) or for a specific user
  Stream<List<OrderModel>> streamOrders({String? userId, String? status}) {
    Query query = _firestore.collection(collection).orderBy('createdAt', descending: true);
    if (userId != null) query = query.where('customerId', isEqualTo: userId);
    if (status != null && status != 'all') query = query.where('status', isEqualTo: status);

  return query.snapshots().map((snap) => snap.docs.map((d) => OrderModel.fromMap(d.id, d.data() as Map<String, dynamic>)).toList());
  }

  Future<String> createOrder(OrderModel order) async {
    final docRef = await _firestore.collection(collection).add(order.toMap());
    return docRef.id;
  }

  Future<void> updateStatus(String id, String status) async {
    await _firestore.collection(collection).doc(id).update({'status': status});
  }

  Future<void> cancelOrder(String id) async {
    await _firestore.collection(collection).doc(id).update({'status': 'cancelled'});
  }
}
