import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart'; // Tu archivo generado

// 1. IMPORTACIÓN DEL PROVIDER: Usamos la ruta local de tu clase AuthProvider.
import 'providers/auth_provider.dart';
import 'providers/ice_cream_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_ice_creams_screen.dart';
import 'screens/create_ice_cream_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  // Asegurarse de que los widgets estén inicializados antes de llamar a funciones nativas
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Opcional: Configuración para emuladores (si los estás usando)
  // if (useEmulator) {
  //   await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //   FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  // }

  runApp(
    // Envolvemos toda la aplicación con ChangeNotifierProvider para el AuthProvider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => IceCreamProvider()),
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
        // '/orders': (context) => OrdersScreen(), // Implementar si es necesario
        // '/profile': (context) => ProfileScreen(), // Implementar si es necesario
      },
    );
  }
}

// Widget que decide qué pantalla mostrar basado en el estado de autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios en el AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.status) {
      case AuthStatus.uninitialized:
        // Mostrar pantalla de carga mientras se verifica el token inicial
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      case AuthStatus.authenticated:
        // El usuario está logueado, ir a la pantalla de inicio
        print('Usuario Autenticado: ${authProvider.userModel?.email} | Rol: ${authProvider.userModel?.role}');
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        // El usuario no está logueado, ir a la pantalla de login
        return const LoginScreen();
    }
  }
}