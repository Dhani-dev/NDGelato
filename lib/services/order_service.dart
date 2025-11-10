import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import 'notification_service.dart';

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

    // Notify admins that a new order was created
    try {
      final notif = NotificationService();
      await notif.createNotification(
        title: 'New order',
        body: 'Order #${order.orderNumber} created by ${order.customerName}',
        target: 'admin',
      );
    } catch (e) {
      // ignore
    }

    return docRef.id;
  }

  Future<void> updateStatus(String id, String status) async {
    await _firestore.collection(collection).doc(id).update({'status': status});
    // After status update, notify the customer
    try {
      final doc = await _firestore.collection(collection).doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final customerId = data['customerId'] as String?;
        final customerName = data['customerName'] as String? ?? '';
        final orderNumber = data['orderNumber'] as int? ?? 0;
        final notif = NotificationService();
        await notif.createNotification(
          title: 'Order status updated',
          body: 'Order #$orderNumber status is now: $status',
          target: 'user',
          userId: customerId,
        );
        // If cancelled, also notify admins
        if (status == 'cancelled') {
          await notif.createNotification(
            title: 'Order cancelled',
            body: 'Order #$orderNumber from $customerName was cancelled',
            target: 'admin',
          );
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> cancelOrder(String id) async {
    await _firestore.collection(collection).doc(id).update({'status': 'cancelled'});

    // Notify admins that a user cancelled an order
    try {
      final doc = await _firestore.collection(collection).doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final customerName = data['customerName'] as String? ?? '';
        final orderNumber = data['orderNumber'] as int? ?? 0;
        final notif = NotificationService();
        await notif.createNotification(
          title: 'Order cancelled',
          body: 'Order #$orderNumber from $customerName was cancelled by the user',
          target: 'admin',
        );
      }
    } catch (e) {
      // ignore notification errors
    }
  }
}
