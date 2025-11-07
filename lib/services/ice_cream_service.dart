import 'package:cloud_firestore/cloud_firestore.dart';
// Para subir imágenes, agrega en pubspec.yaml:
// firebase_storage: ^latest_version
// import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/ice_cream_model.dart';

class IceCreamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance;
  final String collection = 'ice_creams';

  // Create
  Future<String> createIceCream(IceCream iceCream, {File? imageFile}) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile);
      }

      final docRef = await _firestore.collection(collection).add({
        ...iceCream.toMap(),
        if (imageUrl != null) 'imageUrl': imageUrl,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Error creating ice cream: $e');
    }
  }

  // Read
  Stream<List<IceCream>> streamIceCreams() {
    return _firestore
        .collection(collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => IceCream.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Update
  Future<void> updateIceCream(String id, IceCream iceCream, {File? imageFile}) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile);
      }

      await _firestore.collection(collection).doc(id).update({
        ...iceCream.toMap(),
        if (imageUrl != null) 'imageUrl': imageUrl,
      });
    } catch (e) {
      throw Exception('Error updating ice cream: $e');
    }
  }

  // Delete
  Future<void> deleteIceCream(String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting ice cream: $e');
    }
  }

  // Upload image
  Future<String> _uploadImage(File imageFile) async {
    throw UnimplementedError('Para subir imágenes, instala firebase_storage y descomenta el código correspondiente.');
  }
}