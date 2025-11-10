import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../providers/auth_provider.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({Key? key}) : super(key: key);

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notif = Provider.of<NotificationProvider>(context, listen: false);
      notif.startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = NotificationService();
    final auth = Provider.of<AuthProvider>(context, listen: false);
  // notifProv is only needed inside the sheet for mark-as-read actions.
  // We will obtain it lazily there via Provider.of(...)

    // Badge rendered from the stream to reflect real-time unread count
    return StreamBuilder<List<NotificationModel>>(
      stream: service.streamNotifications(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? [];
        final list = all.where((n) {
          if (n.target == 'all') return true;
          if (n.target == 'admin' && auth.userModel?.isAdmin == true) return true;
          if (n.target == 'user' && n.userId == auth.userModel?.uid) return true;
          return false;
        }).toList();

        final unreadCount = list.where((n) => !n.read).length;

        return IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications),
              if (unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            // Open same sheet; _buildSheet uses a StreamBuilder internally too.
            showModalBottomSheet(
              context: context,
              builder: (_) => _buildSheet(context, list),
            );
          },
        );
      },
    );
  }

  Widget _buildSheet(BuildContext context, List items) {
    final notifProv = Provider.of<NotificationProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final service = NotificationService();

    // Usamos StreamBuilder aquí para cumplir la consigna de "uso de StreamBuilder"
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('Notifications', style: Theme.of(context).textTheme.titleMedium),
          ),
          const Divider(),
          SizedBox(
            height: 300,
            child: StreamBuilder<List<NotificationModel>>(
              stream: service.streamNotifications(),
              builder: (context, snapshot) {
                final all = snapshot.data ?? [];
                final list = all.where((n) {
                  if (n.target == 'all') return true;
                  if (n.target == 'admin' && auth.userModel?.isAdmin == true) return true;
                  if (n.target == 'user' && n.userId == auth.userModel?.uid) return true;
                  return false;
                }).toList();

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (list.isEmpty) return const Center(child: Text('No notifications'));

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final n = list[i];
                    return ListTile(
                      leading: Icon(n.read ? Icons.notifications_none : Icons.notifications_active,
                          color: n.read ? Colors.grey : Colors.purple),
                      title: Text(n.title),
                      subtitle: Text(n.body),
                      trailing: n.read
                          ? null
                          : TextButton(
                              onPressed: () async {
                                await notifProv.markAsRead(n.id);
                              },
                              child: const Text('Mark')),
                      onTap: () async {
                        if (!n.read) await notifProv.markAsRead(n.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
