import 'dart:io'; // Import required for File handling
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  // 1. ROLE & LANGUAGE
  int _userRole = 0;
  String _languageCode = 'en';

  // 2. FARMER BASIC DATA
  String _farmerName = "Rajesh Kumar";
  String _farmerPhone = "9876543210";
  File? _profileImage; // New variable to store the profile photo

  // 3. FARM DETAILS (UPDATED)
  // We still keep the list for multi-crop if needed later, but focus on the 'current' selection
  final List<String> _myCrops = ["Paddy (Rice)"]; 
  String _selectedCrop = "Paddy (Rice)";    
  String _season = "Autumn (June-Oct)";
  String _district = "Khordha";
  String _landSize = "2.5 Acres";

  // Getters
  int get userRole => _userRole;
  String get languageCode => _languageCode;
  String get farmerName => _farmerName;
  String get farmerPhone => _farmerPhone;
  File? get profileImage => _profileImage; // Getter for the image
  
  String get selectedCrop => _selectedCrop;
  String get season => _season;
  String get district => _district;
  String get landSize => _landSize;
  List<String> get myCrops => _myCrops; // Backward compatibility

  // Setters
  void setUserRole(int role) {
    _userRole = role;
    notifyListeners();
  }

  void setLanguage(String code) {
    _languageCode = code;
    notifyListeners();
  }

  // --- NEW: SET FARM DETAILS FROM INPUT SCREEN ---
  void setFarmDetails({
    required String crop,
    required String season,
    required String district,
    required String area,
  }) {
    _selectedCrop = crop;
    _season = season;
    _district = district;
    _landSize = "$area Acres";
    
    // Ensure the selected crop is in our list
    if (!_myCrops.contains(crop)) {
      _myCrops.add(crop);
    }
    
    notifyListeners();
  }

  // Updated Profile Function (Now accepts an image file)
  void updateProfile(String name, String phone, List<String> crops, String size, String dist, File? image) {
    _farmerName = name;
    _farmerPhone = phone;
    
    // Update image only if a new one is selected (not null)
    if (image != null) {
      _profileImage = image;
    }

    // We don't overwrite the specific session details here necessarily, 
    // unless you want profile edit to reset everything. 
    // For now, let's just update basic info.
    notifyListeners();
  }
  
  // Simple crop switch if needed
  void selectCrop(String crop) {
    _selectedCrop = crop;
    notifyListeners();
  }
}