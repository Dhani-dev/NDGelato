// Clases de datos para la aplicación
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  // Campo adicional para distinguir entre usuarios normales y administradores
  final String role; // Puede ser 'user' o 'admin'
  
  bool get isAdmin => role == 'admin';

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    this.role = 'user',
  });

  // Factory constructor para crear un UserModel desde un Map (Firestore document)
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] as String,
      email: data['email'] as String,
      displayName: data['displayName'] as String? ?? 'Usuario',
      photoUrl: data['photoUrl'] as String? ?? '',
      role: data['role'] as String? ?? 'user', // Valor predeterminado 'user'
    );
  }

  // Método para convertir el UserModel a un Map (para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': DateTime.now().toIso8601String(), // Agregar marca de tiempo de creación
    };
  }

  // IMPLEMENTACIÓN REQUERIDA DE EQUATABLE
  // Define las propiedades que, si son iguales, harán que dos UserModels sean iguales.
  @override
  List<Object> get props => [uid, email, displayName, photoUrl, role];
}