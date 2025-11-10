import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
// Simple date formatting without adding new package
import '../services/order_service.dart';
import '../utils/snack_utils.dart';
import '../models/order_model.dart';

class OrdersAdminScreen extends StatefulWidget {
  const OrdersAdminScreen({super.key});

  @override
  State<OrdersAdminScreen> createState() => _OrdersAdminScreenState();
}

class _OrdersAdminScreenState extends State<OrdersAdminScreen> {
  final OrderService _service = OrderService();
  String _filter = 'all';
  // ✅ CORRECCIÓN: Variable para almacenar la última lista válida.
  List<OrderModel> _currentOrders = [];

  // Lista de estados posibles incluyendo delivered y cancelled
  final List<String> tabs = ['all', 'pending', 'paid', 'preparing', 'ready', 'delivered', 'cancelled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrator Panel'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, idx) {
                final t = tabs[idx];
                final selected = t == _filter;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ChoiceChip(
                    label: Text(t[0].toUpperCase() + t.substring(1)),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = t), // Solo actualiza el filtro
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              // Al cambiar _filter, se crea un nuevo stream
              stream: _service.streamOrders(status: _filter == 'all' ? null : _filter),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }

                // 1. Si el stream está esperando el primer dato
                if (snap.connectionState == ConnectionState.waiting) {
                  // Muestra el spinner SOLO si no tenemos datos antiguos que mostrar.
                  if (_currentOrders.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Si tenemos datos antiguos, los usamos abajo.
                }

                // 2. Si recibimos datos nuevos y válidos
                if (snap.hasData && snap.data != null) {
                    _currentOrders = snap.data!;
                }

                // 3. Usamos la lista de órdenes más reciente (ya sea la nueva o la cacheadada)
                final orders = _currentOrders; 
                
                if (orders.isEmpty) {
                    // Si la lista cacheadada está vacía y ya no estamos esperando, muestra "No orders"
                    return const Center(child: Text('No orders'));
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orders.length,
                  itemBuilder: (context, i) => _buildOrderCard(orders[i]),
                );
              },
            ),
          )
        ],
      ),
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

  Widget _buildOrderCard(OrderModel order) {
    String df(DateTime d) {
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(d.day)}/${two(d.month)}/${d.year}, ${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(order.customerName.isNotEmpty ? order.customerName[0].toUpperCase() : 'U')),
                const SizedBox(width: 12),
                Expanded(child: Text(order.items.isNotEmpty ? order.items[0]['name'] : 'Order', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                _statusBadge(order.status),
              ],
            ),
            const SizedBox(height: 12),
            Text('Order #:', style: TextStyle(color: Colors.grey[700])),
            Align(alignment: Alignment.centerRight, child: Text('${order.orderNumber}')),
            const SizedBox(height: 8),
            Text('Date:', style: TextStyle(color: Colors.grey[700])),
            Align(alignment: Alignment.centerRight, child: Text(df(order.createdAt))),
            const SizedBox(height: 8),
            Text('Total:', style: TextStyle(color: Colors.grey[700])),
            Align(alignment: Alignment.centerRight, child: Text('\$${order.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Text('Items: ${order.items.map((i) => i['name']).join(', ')}'),
            const SizedBox(height: 4),
            const SizedBox(height: 12),
            Row(
              children: _actionButtons(order),
            )
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = Colors.grey;
    String label = status[0].toUpperCase() + status.substring(1);
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
      case 'cancelled':
        color = Colors.red;
        break;
      case 'delivered':
        color = Colors.purpleAccent;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.6))),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }

  List<Widget> _actionButtons(OrderModel order) {
    final List<Widget> buttons = [];
    final next = _nextStatus(order.status);
    if (next != null) {
      buttons.add(Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
          onPressed: () async {
            await _service.updateStatus(order.id!, next);
                  if (mounted) showStyledSnackBar(context, title: 'Order updated', message: 'Order "${order.items.isNotEmpty ? order.items[0]['name'] : ''}" -> ${_labelFor(next)}', success: next == 'paid');
          },
          child: Text('Mark as: ${_labelFor(next)}'),
        ),
      ));
    }

    // Allow cancel for early states
    if (order.status == 'pending' || order.status == 'paid') {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 12));
      buttons.add(OutlinedButton(
        onPressed: () async {
          await _service.cancelOrder(order.id!);
          if (mounted) showStyledSnackBar(context, title: 'Order cancelled', message: 'Order #${order.orderNumber} cancelled', success: false);
        },
        child: const Text('Cancel'),
      ));
    }

    return buttons;
  }

  String _labelFor(String s) {
    if (s == 'preparing') return 'In preparation';
    if (s == 'ready') return 'Ready';
    if (s == 'paid') return 'Paid';
    if (s == 'delivered') return 'Delivered';
    return s;
  }

  String? _nextStatus(String current) {
    switch (current) {
      case 'pending':
        return 'paid';
      case 'paid':
        return 'preparing';
      case 'preparing':
        return 'ready';
      case 'ready':
        return 'delivered';
      default:
        return null;
    }
  }
}