import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../providers/auth_provider.dart';
import '../services/order_service.dart';
import '../models/order_model.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final OrderService _service = OrderService();
  final Map<String, String> _prevStatus = {};

  void _checkStatusChange(BuildContext context, List<OrderModel> orders) {
    for (final order in orders) {
      final old = _prevStatus[order.id] ?? '';
      if (old.isNotEmpty && old != order.status) {
        // Asegurarse de que el widget aún esté montado antes de mostrar el SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order "${order.items.isNotEmpty ? order.items[0]['name'] : ''}" changed to ${order.status}'))
          );
        }
      }
      _prevStatus[order.id!] = order.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (auth.user?.uid == null) return const Scaffold(body: Center(child: Text('Not authenticated')));

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders'), backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: StreamBuilder<List<OrderModel>>(
        stream: _service.streamOrders(userId: auth.user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];
          
          // --- ✅ AQUÍ ESTÁ LA CORRECCIÓN ---
          // Se programa la verificación de estado para después del 'build'
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) { // Verificar si el widget sigue en el árbol
              _checkStatusChange(context, orders);
            }
          });
          // --- FIN DE LA CORRECCIÓN ---
          
          if (orders.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, i) => _buildOrderCard(context, orders[i], _service),
          );
        },
      ),
      // Dev-only FAB to create a sample order for testing realtime behavior
      floatingActionButton: kDebugMode
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/create_order'),
              label: const Text('Create Order'),
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
            Expanded(child: Text(order.items.isNotEmpty ? order.items[0]['name'] : 'Order', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
            _statusBadge(order.status),
          ]),
          const SizedBox(height: 12),
          Text('Order #: ${order.orderNumber}'),
          Text('Date: ${df(order.createdAt)}'),
          const SizedBox(height: 8),
          Text('Total: \$${order.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Items: ${order.items.map((i) => i['name']).join(', ')}'),
          const SizedBox(height: 12),
          _progressBar(progress),
          const SizedBox(height: 12),
          if (order.status == 'pending')
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                await service.cancelOrder(order.id!);
                // Esta llamada al SnackBar SÍ es correcta porque está
                // dentro de un callback (onPressed), no de un 'build'.
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