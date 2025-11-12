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

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _userModel = null;
      _status = AuthStatus.unauthenticated;
    } else {
      _user = firebaseUser;
      _userModel = await _authService.getUserProfile(firebaseUser.uid);
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      _status = AuthStatus.uninitialized;
      notifyListeners();
      await _authService.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      // Revertir a no autenticado en caso de error
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
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
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> refreshUserProfile() async {
    if (_user == null) return;
    try {
      final profile = await _authService.getUserProfile(_user!.uid);
      if (profile != null) {
        _userModel = profile;
        notifyListeners();
      }
    } catch (e) {
      // No bloqueante: solo logueamos el error
      debugPrint('Error refreshing user profile: $e');
    }
  }
}