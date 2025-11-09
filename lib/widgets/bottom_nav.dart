import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        // Call parent callback first. Then perform a safe fallback navigation to ensure
        // taps always navigate even if a parent did not perform navigation for some screens.
        onTap: (index) {
          try {
            onTap(index);
          } catch (_) {}

          // Fallback navigation (idempotent): map index -> route
          String route = '/';
          if (index == 0) route = '/';
          else if (index == 1) route = '/my_ice_creams';
          else if (index == 2) route = '/orders';
          else if (index == 3) route = '/profile';

          // Use pushReplacementNamed to avoid stacking many routes
          try {
            if (ModalRoute.of(context)?.settings.name != route) {
              Navigator.pushReplacementNamed(context, route);
            }
          } catch (_) {}
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.secondaryTextColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.ice_skating_outlined),
            activeIcon: Icon(Icons.ice_skating),
            label: 'My Ice Creams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}