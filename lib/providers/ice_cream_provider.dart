import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/ice_cream_model.dart';
import '../services/ice_cream_service.dart';

class IceCreamProvider with ChangeNotifier {
  final IceCreamService _service = IceCreamService();
  List<IceCream> _iceCreams = [];
  bool _isLoading = false;
  String? _error;

  List<IceCream> get iceCreams => _iceCreams;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final List<String> availableFlavors = [
    'Strawberry',
    'Chocolate',
    'Vanilla',
    'Mint',
    'Blueberry',
    'Mango',
    'Pistachio',
    'Cookies & Cream',
  ];

  final List<String> availableToppings = [
    'Sprinkles',
    'Cherry',
    'Chocolate Chips',
    'Whipped Cream',
    'Caramel',
    'Cookie',
  ];

  // Create
  Future<void> createIceCream(IceCream iceCream, {File? imageFile}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.createIceCream(iceCream, imageFile: imageFile);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Listen to ice creams
  void startListeningToIceCreams() {
    _service.streamIceCreams().listen(
      (iceCreams) {
        _iceCreams = iceCreams;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  // Delete
  Future<void> deleteIceCream(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.deleteIceCream(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}