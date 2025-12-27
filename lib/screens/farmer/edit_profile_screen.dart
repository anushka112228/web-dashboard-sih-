import 'dart:io'; // Needed for File handling
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  
  // We keep these for existing logic, even if we focus on Name/Phone
  late TextEditingController _landController;
  String _selectedCrop = "Paddy (Rice)";
  String _selectedDistrict = "Khordha";

  // Image Handling Variables
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final state = Provider.of<AppState>(context, listen: false);
    _nameController = TextEditingController(text: state.farmerName);
    _phoneController = TextEditingController(text: state.farmerPhone);
    _landController = TextEditingController(text: state.landSize);
    _selectedCrop = state.selectedCrop;
    _selectedDistrict = state.district;
    
    // Load existing image if available
    _pickedImage = state.profileImage;
  }

  // FUNCTION: Pick Image from Gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- 1. PROFILE PHOTO SECTION ---
            Center(
              child: Stack(
                children: [
                  // The Avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.green[50],
                    backgroundImage: _pickedImage != null 
                        ? FileImage(_pickedImage!) 
                        : null,
                    child: _pickedImage == null 
                        ? const Icon(Icons.person, size: 60, color: Colors.green) 
                        : null,
                  ),
                  // The Camera Icon Button
                  Positioned(
                    bottom: 0, 
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage, // Trigger picker on tap
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3)
                        ),
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text("Tap camera to upload", style: TextStyle(color: Colors.grey, fontSize: 12)),
            
            const SizedBox(height: 30),

            // --- 2. NAME & PHONE INPUTS ---
            _buildLabel("Full Name"),
            TextField(controller: _nameController, decoration: _inputDecor("Enter Name")),
            const SizedBox(height: 20),

            _buildLabel("Phone Number"),
            TextField(
              controller: _phoneController, 
              keyboardType: TextInputType.phone, 
              decoration: _inputDecor("Enter Phone")
            ),
            const SizedBox(height: 30),

            // --- 3. SAVE BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: () {
                  // Save everything to AppState
                  Provider.of<AppState>(context, listen: false).updateProfile(
                    _nameController.text,
                    _phoneController.text,
                    [_selectedCrop],
                    _landController.text,
                    _selectedDistrict,
                    _pickedImage // Pass the image file
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile Updated Successfully! 📸"), backgroundColor: Colors.green)
                  );
                },
                child: const Text("SAVE CHANGES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Align(alignment: Alignment.centerLeft, child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))));

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.green)),
      filled: true,
      fillColor: const Color(0xFFF8F9FA)
    );
  }
}