import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'notifications';

  // Create a notification
  Future<String> createNotification({
    required String title,
    required String body,
    required String target,
    String? userId,
  }) async {
    final docRef = await _firestore.collection(collection).add({
      'title': title,
      'body': body,
      'target': target,
      if (userId != null) 'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
    return docRef.id;
  }

  // Stream all notifications (we'll filter on client side by role/user)
  Stream<List<NotificationModel>> streamNotifications() {
    return _firestore
        .collection(collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
    .map((snap) => snap.docs
      .map((d) => NotificationModel.fromMap(d.id, d.data()))
      .toList());
  }

  Future<void> markAsRead(String id) async {
    await _firestore.collection(collection).doc(id).update({'read': true});
  }
}
