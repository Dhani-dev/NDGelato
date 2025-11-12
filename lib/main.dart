import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'providers/auth_provider.dart';
import 'providers/ice_cream_provider.dart';
import 'providers/order_provider.dart';
import 'providers/notification_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_ice_creams_screen.dart';
import 'screens/create_ice_cream_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/orders_wrapper.dart';
import 'screens/create_order_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => IceCreamProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ND Gelato App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFDC2483)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/my_ice_creams': (context) => const MyIceCreamsScreen(),
        '/create': (context) => const CreateIceCreamScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/orders': (context) => const OrdersWrapper(),
  '/create_order': (context) => CreateOrderScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.status) {
      case AuthStatus.uninitialized:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      case AuthStatus.authenticated:
        print('Usuario Autenticado: ${authProvider.userModel?.email} | Rol: ${authProvider.userModel?.role}');
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}