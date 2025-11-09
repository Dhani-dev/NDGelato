import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kDebugMode;
// small formatter helper instead of intl
import '../providers/auth_provider.dart';
import '../providers/ice_cream_provider.dart';
import '../services/order_service.dart';
import '../models/order_model.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final OrderService _service = OrderService();
  List<OrderModel> _orders = [];
  Stream<List<OrderModel>>? _stream;
  late Map<String, String> _prevStatus;
  StreamSubscription<List<OrderModel>>? _sub;

  @override
  void initState() {
    super.initState();
    _prevStatus = {};
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final uid = auth.user?.uid;
      if (uid == null) return;
      _stream = _service.streamOrders(userId: uid);
      _sub = _stream!.listen((list) {
        // Compare statuses and notify for changes
        for (final o in list) {
          final old = _prevStatus[o.id] ?? '';
          if (old.isNotEmpty && old != o.status) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order "${o.iceCreamName}" changed to ${o.status}')));
          }
        }
        _prevStatus = {for (var o in list) o.id!: o.status};
        setState(() => _orders = list);
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (auth.user?.uid == null) return const Scaffold(body: Center(child: Text('Not authenticated')));

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders'), backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: _orders.isEmpty
          ? const Center(child: Text('No orders found'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _orders.length,
              itemBuilder: (context, i) => _buildOrderCard(context, _orders[i], _service),
            ),
      // Dev-only FAB to create a sample order for testing realtime behavior
      floatingActionButton: kDebugMode
          ? FloatingActionButton.extended(
              onPressed: () async {
                final iceProvider = Provider.of<IceCreamProvider>(context, listen: false);
                final sample = iceProvider.iceCreams.isNotEmpty ? iceProvider.iceCreams.first : null;
                final uid = Provider.of<AuthProvider>(context, listen: false).user!.uid;
                final name = Provider.of<AuthProvider>(context, listen: false).userModel?.displayName ?? 'User';
                final rnd = Random();
                final order = OrderModel(
                  orderNumber: rnd.nextInt(900000) + 100000,
                  iceCreamId: sample?.id ?? 'sample-id',
                  iceCreamName: sample?.name ?? 'Sample Ice Cream',
                  customerId: uid,
                  customerName: name,
                  total: sample != null ? (sample.price ?? 9.99) : 9.99,
                  flavors: sample != null ? List<String>.from(sample.flavors ?? ['vanilla']) : ['vanilla'],
                  toppings: sample != null ? List<String>.from(sample.toppings ?? []) : [],
                );

                try {
                  final id = await _service.createOrder(order);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dev order created: $id')));
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating dev order: $e')));
                }
              },
              label: const Text('Create Order (dev)'),
              icon: const Icon(Icons.add_shopping_cart),
            )
          : null,
      bottomNavigationBar: BottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/my_ice_creams');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/orders');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
      );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order, OrderService service) {
    String df(DateTime d) {
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(d.day)}/${two(d.month)}/${d.year}';
    }
    int progress = _progressIndex(order.status);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.icecream),
            const SizedBox(width: 8),
            Expanded(child: Text(order.iceCreamName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
            _statusBadge(order.status),
          ]),
          const SizedBox(height: 12),
          Text('Order #: ${order.orderNumber}'),
          Text('Date: ${df(order.createdAt)}'),
          const SizedBox(height: 8),
          Text('Total: \$${order.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Flavors: ${order.flavors.join(', ')}'),
          Text('Toppings: ${order.toppings.join(', ')}'),
          const SizedBox(height: 12),
          _progressBar(progress),
          const SizedBox(height: 12),
          if (order.status == 'pending')
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                await service.cancelOrder(order.id!);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order cancelled')));
              },
              child: const Text('Cancel Order'),
            )
        ]),
      ),
    );
  }

  Widget _progressBar(int step) {
    // 0: pending, 1: paid, 2: preparing, 3: ready, 4: delivered
    final total = 4;
    return Row(
      children: List.generate(total, (i) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            decoration: BoxDecoration(
              color: i <= step ? Colors.pink : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }),
    );
  }

  Widget _statusBadge(String status) {
    Color color = Colors.grey;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'paid':
        color = Colors.green;
        break;
      case 'preparing':
        color = Colors.blue;
        break;
      case 'ready':
        color = Colors.purple;
        break;
      case 'delivered':
        color = Colors.purpleAccent;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.6))),
      child: Text(status[0].toUpperCase() + status.substring(1), style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }

  int _progressIndex(String status) {
    switch (status) {
      case 'pending':
        return 0;
      case 'paid':
        return 1;
      case 'preparing':
        return 2;
      case 'ready':
        return 3;
      case 'delivered':
        return 4;
      default:
        return 0;
    }
  }
}
