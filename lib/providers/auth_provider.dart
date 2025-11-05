import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

// Este provider mantiene el estado de la autenticación y el perfil del usuario
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user; // Usuario de Firebase Auth
  UserModel? _userModel; // Perfil de usuario de Firestore
  AuthStatus _status = AuthStatus.uninitialized;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  AuthStatus get status => _status;

  // Constructor que escucha los cambios de estado de Auth
  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  // Maneja los cambios de estado de Firebase Auth
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _userModel = null;
      _status = AuthStatus.unauthenticated;
    } else {
      _user = firebaseUser;
      // Obtener el perfil completo de Firestore
      _userModel = await _authService.getUserProfile(firebaseUser.uid);
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  // -------------------------
  // Lógica de Autenticación
  // -------------------------

  Future<void> signIn({required String email, required String password}) async {
    try {
      _status = AuthStatus.uninitialized;
      notifyListeners();
      await _authService.signInWithEmailAndPassword(email: email, password: password);
      // El _onAuthStateChanged manejará la actualización final del estado
    } catch (e) {
      // Revertir a no autenticado en caso de error
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow; // Re-lanzar el error para mostrarlo en la UI
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _status = AuthStatus.uninitialized;
      notifyListeners();
      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      // El _onAuthStateChanged manejará la actualización final del estado
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow; // Re-lanzar el error
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // -------------------------
  // Lógica de Perfil (futuras implementaciones)
  // -------------------------

  // En el futuro, aquí podríamos agregar lógica para actualizar el perfil en Firestore
}