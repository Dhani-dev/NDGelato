import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

// Este servicio maneja la comunicación con Firebase Auth y Firestore (colección 'users')
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Dominio especial para usuarios administradores
  static const String _adminDomain = 'ndgelato.com';

  // Stream para detectar cambios en el estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // -------------------------
  // Métodos de Autenticación
  // -------------------------

  // 1. Registro de Usuario
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // 1. Crear el usuario en Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(code: 'user-creation-failed');
      }

      // 2. Determinar el rol del usuario
      String role = 'user';
      if (email.endsWith(_adminDomain)) {
        role = 'admin';
      }

      // 3. Crear el modelo de usuario para Firestore
      final newUser = UserModel(
        uid: firebaseUser.uid,
        email: email,
        displayName: displayName,
        role: role,
      );

      // 4. Guardar el perfil inicial en Firestore
      await _db.collection('users').doc(firebaseUser.uid).set(newUser.toMap());

      // 5. Actualizar el display name en Firebase Auth
      await firebaseUser.updateDisplayName(displayName);

      return newUser;
    } on FirebaseAuthException catch (e) {
      // Manejo de errores de autenticación
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      // Otros errores
      throw Exception('Ocurrió un error inesperado al registrar: $e');
    }
  }

  // 2. Inicio de Sesión
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Iniciar sesión en Firebase Authentication
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(code: 'user-not-found');
      }

      // 2. Obtener el perfil del usuario desde Firestore
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (!doc.exists) {
        // Esto no debería pasar si el registro fue exitoso, pero es una buena medida de seguridad
        await firebaseUser.delete(); // Limpiar el registro de Auth
        throw Exception('Perfil de usuario no encontrado en Firestore.');
      }

      return UserModel.fromMap(doc.data()!);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      throw Exception('Ocurrió un error inesperado al iniciar sesión: $e');
    }
  }

  // 3. Cierre de Sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // -------------------------
  // Métodos de Perfil (Firestore)
  // -------------------------

  // Obtener el modelo de usuario actual de Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error al obtener perfil de usuario: $e');
      return null;
    }
  }

  // Función auxiliar para manejar los códigos de error de Firebase
  String _handleAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El formato del correo electrónico es inválido.';
      case 'user-not-found':
        return 'No se encontró un usuario con este correo.';
      case 'wrong-password':
        return 'La contraseña es incorrecta.';
      case 'email-already-in-use':
        return 'El correo electrónico ya está registrado.';
      case 'weak-password':
        return 'La contraseña es demasiado débil (mínimo 6 caracteres).';
      default:
        return 'Error de autenticación: $code';
    }
  }
}