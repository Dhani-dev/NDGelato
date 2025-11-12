import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'auth_provider.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _service = NotificationService();
  List<NotificationModel> _all = [];

  List<NotificationModel> get all => List.unmodifiable(_all);

  // Start listening
  void startListening() {
    _service.streamNotifications().listen((items) {
      _all = items;
      notifyListeners();
    }, onError: (e) {
      // ignore for now
    });
  }

  // Get notifications for users
  List<NotificationModel> forUser(AuthProvider auth) {
    final user = auth.userModel;
    if (user == null) return [];

    final isAdmin = user.isAdmin;

    return _all.where((n) {
      if (n.target == 'all') return true;
      if (n.target == 'admin' && isAdmin) return true;
      if (n.target == 'user' && n.userId == user.uid) return true;
      return false;
    }).toList();
  }

  Future<void> markAsRead(String id) async {
    try {
      await _service.markAsRead(id);
      final idx = _all.indexWhere((e) => e.id == id);
      if (idx >= 0) {
        final updated = NotificationModel(
          id: _all[idx].id,
          title: _all[idx].title,
          body: _all[idx].body,
          target: _all[idx].target,
          userId: _all[idx].userId,
          createdAt: _all[idx].createdAt,
          read: true,
        );
        _all[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      // ignore
    }
  }
}
