import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav.dart';
import '../utils/file_utils.dart';
import '../providers/auth_provider.dart';
import '../providers/ice_cream_provider.dart';
import '../services/auth_service.dart';
import '../widgets/notification_bell.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Asegura que los datos necesarios (como los helados para las estadísticas) estén escuchando.
      // Esto es independiente de la lógica de la foto de perfil.
      Provider.of<IceCreamProvider>(
        context,
        listen: false,
      ).startListeningToIceCreams();
    });
  }

  /// Función para seleccionar y subir la imagen de perfil
  Future<void> _pickAndUploadImage(String uid) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      // 1. Crear una referencia única para Firebase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // La referencia se guarda en 'user_photos/UID-TIMESTAMP.jpg'
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_photos')
          .child('$uid-$timestamp.jpg');

      UploadTask uploadTask;
      if (kIsWeb) {
        // En Web, usar putData con bytes
        final Uint8List data = await picked.readAsBytes();
        uploadTask = ref.putData(
          data,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // En móvil/desktop, usar File y putFile
        final file = createFile(picked.path); // Requiere la función createFile
        uploadTask = ref.putFile(file);
      }

      // 2. Esperar a que la carga se complete y obtener la URL
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // 3. Actualizar el documento del usuario en Firestore (campo 'photoUrl')
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'photoUrl': downloadUrl,
      });

      // 4. Actualizar el usuario de Firebase Auth
      final current = FirebaseAuth.instance.currentUser;
      if (current != null) {
        await current.updatePhotoURL(downloadUrl);
        await current.reload();
      }

      // 5. Actualizar el AuthProvider para que la UI se refresque inmediatamente
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshUserProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil actualizada')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error subiendo imagen: $e. Revisa las reglas de Storage.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final iceProvider = Provider.of<IceCreamProvider>(context);
    final userModel = auth.userModel;

    // Si no hay usuario, redirigir a la ruta inicial
    if (userModel == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/');
      });
      return const Scaffold();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
        actions: const [NotificationBell()],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 3, // Profile es el índice 3
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/my_ice_creams');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/orders');
          }
          // Si index == 3, nos quedamos aquí
        },
      ),
      body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Tarjeta de Perfil ---
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24.0,
                        horizontal: 16.0,
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[200],
                                // Muestra la foto de perfil o una imagen por defecto
                                backgroundImage: userModel.photoUrl.isNotEmpty
                                    ? NetworkImage(userModel.photoUrl)
                                          as ImageProvider
                                    : const AssetImage(
                                        'assets/logo_gelato.png',
                                      ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: InkWell(
                                  onTap: _isUploading
                                      ? null
                                      : () async {
                                          final uid = auth.user?.uid;
                                          if (uid == null) return;
                                          await _pickAndUploadImage(uid);
                                        },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.pink,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: _isUploading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            userModel.displayName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextButton.icon(
                            onPressed: () async {
                              final newName = await _editDisplayName(context, userModel.displayName);
                              if (newName != null && newName.trim().isNotEmpty) {
                                final authService = AuthService();
                                try {
                                  await authService.updateUserProfile(uid: userModel.uid, displayName: newName.trim());
                                  // Refresh provider
                                  await Provider.of<AuthProvider>(context, listen: false).refreshUserProfile();
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Display name updated')));
                                } catch (e) {
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                }
                              }
                            },
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit name'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userModel.email,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          // Badge de Admin (si aplica)
                          if (userModel.isAdmin) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings,
                                    size: 16,
                                    color: Colors.purple[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Admin',
                                    style: TextStyle(
                                      color: Colors.purple[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // --- Tarjeta de Estadísticas ---
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statistics',
                            style: TextStyle(
                              color: Colors.pink[700],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.pink[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.icecream, color: Colors.pink),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ice Creams Created',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${iceProvider.iceCreams.where((c) => c.authorId == userModel.uid).length}',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // --- Botón de Cerrar Sesión ---
                  OutlinedButton.icon(
                    onPressed: () {
                      // Primero vamos a la ruta inicial '/'
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                      // El signOut cambiará el estado y AuthWrapper manejará la navegación
                      auth.signOut();
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Log Out',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<String?> _editDisplayName(BuildContext context, String current) async {
    final controller = TextEditingController(text: current);
    return showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit display name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Display name'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text('Save')),
          ],
        );
      },
    );
  }
}
