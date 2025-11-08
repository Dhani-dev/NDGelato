import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../utils/file_utils.dart';

import '../providers/auth_provider.dart';
import '../providers/ice_cream_provider.dart';

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
      Provider.of<IceCreamProvider>(context, listen: false).startListeningToIceCreams();
    });
  }

  Future<void> _pickAndUploadImage(String uid) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      final ref = FirebaseStorage.instance.ref().child('user_photos').child('$uid.jpg');

      UploadTask uploadTask;
      if (kIsWeb) {
        // On web, use putData with bytes
        final Uint8List data = await picked.readAsBytes();
        uploadTask = ref.putData(
          data,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // On mobile/desktop, use File and putFile
        final file = createFile(picked.path);
        uploadTask = ref.putFile(file);
      }

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update Firestore user document
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'photoUrl': downloadUrl});

      // Update FirebaseAuth user as well
      final current = FirebaseAuth.instance.currentUser;
      if (current != null) {
        await current.updatePhotoURL(downloadUrl);
        await current.reload();
      }

      // Refresh provider's userModel so UI updates immediately
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshUserProfile();

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto de perfil actualizada')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error subiendo imagen: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final iceProvider = Provider.of<IceCreamProvider>(context);
    final userModel = auth.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: userModel == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: userModel.photoUrl.isNotEmpty
                                    ? NetworkImage(userModel.photoUrl) as ImageProvider
                                    : const AssetImage('assets/logo_gelato.png'),
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
                                    decoration: BoxDecoration(color: Colors.pink, borderRadius: BorderRadius.circular(8)),
                                    child: _isUploading
                                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(userModel.displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text(userModel.email, style: TextStyle(color: Colors.grey[700])),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Statistics', style: TextStyle(color: Colors.pink[700], fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.pink[50], borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                Icon(Icons.icecream, color: Colors.pink),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Ice Creams Created', style: TextStyle(color: Colors.grey[700])),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${iceProvider.iceCreams.where((c) => c.authorId == userModel.uid).length}',
                                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await auth.signOut();
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text('Log Out', style: TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ],
              ),
            ),
    );
  }
}
