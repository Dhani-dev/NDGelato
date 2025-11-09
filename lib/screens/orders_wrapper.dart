import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'orders_admin_screen.dart';
import 'my_orders_screen.dart';

class OrdersWrapper extends StatelessWidget {
  const OrdersWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final role = auth.userModel?.role ?? 'user';
    if (role == 'admin') {
      return const OrdersAdminScreen();
    }
    return const MyOrdersScreen();
  }
}
