import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ice_cream_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../services/order_service.dart';
import '../models/order_model.dart';

class CreateOrderScreen extends StatelessWidget {
  CreateOrderScreen({Key? key}) : super(key: key);

  final OrderService _service = OrderService();

  @override
  Widget build(BuildContext context) {
    final iceProvider = Provider.of<IceCreamProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Order'), backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: iceProvider.iceCreams.length,
              itemBuilder: (context, i) {
                final ice = iceProvider.iceCreams[i];
                final inOrder = orderProv.items.indexWhere((e) => e['id'] == ice.id) >= 0;
                final qty = inOrder ? orderProv.items.firstWhere((e) => e['id'] == ice.id)['quantity'] as int : 0;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.icecream),
                    title: Text(ice.name),
                    subtitle: Text('\$${ice.price.toStringAsFixed(2)}'),
                    trailing: SizedBox(
                      width: 140,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => orderProv.decrementOrRemove(ice.id!),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(qty.toString()),
                          IconButton(
                            onPressed: () => orderProv.addOrIncrement(ice),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Total: \$${orderProv.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: orderProv.items.isEmpty
                      ? null
                      : () async {
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          final uid = auth.user?.uid;
                          if (uid == null) return;
                          final name = auth.userModel?.displayName ?? 'User';
                          final rnd = Random();
                          final order = OrderModel(
                            orderNumber: rnd.nextInt(900000) + 100000,
                            items: List<Map<String, dynamic>>.from(orderProv.items),
                            customerId: uid,
                            customerName: name,
                            total: orderProv.total,
                          );

                          try {
                            final id = await _service.createOrder(order);
                            orderProv.clear();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order placed: $id')));
                              Navigator.pushReplacementNamed(context, '/orders');
                            }
                          } catch (e) {
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error placing order: $e')));
                          }
                        },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    child: Text('Place Order', style: TextStyle(fontSize: 16)),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
