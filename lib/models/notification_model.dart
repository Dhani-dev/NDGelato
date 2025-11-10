import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String target; // 'all' | 'admin' | 'user'
  final String? userId; // when target == 'user'
  final DateTime createdAt;
  final bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.target,
    this.userId,
    required this.createdAt,
    this.read = false,
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> data) {
    return NotificationModel(
      id: id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      target: data['target'] as String? ?? 'all',
      userId: data['userId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'target': target,
      if (userId != null) 'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'read': read,
    };
  }
}
