import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import 'farmer_home.dart';

class CropInputScreen extends StatefulWidget {
  const CropInputScreen({super.key});

  @override
  State<CropInputScreen> createState() => _CropInputScreenState();
}

class _CropInputScreenState extends State<CropInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _areaController = TextEditingController();

  // --- 1. CROP TYPES ---
  final List<String> _cropTypes = [
    "Paddy (Rice)", "Groundnut", "Potato", "Urad", "Sesame", "Maize", 
    "Moong Dal", "Wheat", "Sugarcane", "Mustard", "Ragi", "Jute", 
    "Horsegram", "Rapeseed"
  ];
  String? _selectedCrop;

  // --- 2. SEASONS ---
  final List<String> _seasons = [
    "Autumn (June-Oct)", 
    "Winter (Nov-Feb)", 
    "Summer (Feb-May)"
  ];
  String? _selectedSeason;

  // --- 3. DISTRICTS (Odisha) ---
  final List<String> _districts = [
    "Angul", "Balangir", "Balasore", "Bargarh", "Bhadrak", "Boudh", 
    "Cuttack", "Deogarh", "Dhenkanal", "Gajapati", "Ganjam", "Jagatsinghpur", 
    "Jajpur", "Jharsuguda", "Kalahandi", "Kandhamal", "Kendrapara", "Kendujhar", 
    "Khordha", "Koraput", "Malkangiri", "Mayurbhanj", "Nabarangpur", "Nayagarh", 
    "Nuapada", "Puri", "Rayagada", "Sambalpur", "Subarnapur", "Sundargarh"
  ];
  String? _selectedDistrict;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Farm Configuration", 
          style: GoogleFonts.poppins(
            color: const Color(0xFF1B5E20), 
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5
          )
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Configure your farm details to get precise AI predictions.",
                style: GoogleFonts.openSans(fontSize: 14, color: Colors.grey[600], height: 1.5),
              ),
              const SizedBox(height: 35),

              // --- 1. CROP SELECTION ---
              _buildSectionLabel("Crop Type"),
              _buildAnimatedDropdown(
                hint: "Select Crop",
                value: _selectedCrop,
                items: _cropTypes,
                onChanged: (val) => setState(() => _selectedCrop = val),
              ),
              const SizedBox(height: 25),

              // --- 2. SEASON SELECTION ---
              _buildSectionLabel("Growing Season"),
              _buildAnimatedDropdown(
                hint: "Select Season",
                value: _selectedSeason,
                items: _seasons,
                onChanged: (val) => setState(() => _selectedSeason = val),
              ),
              const SizedBox(height: 25),

              // --- 3. DISTRICT SELECTION ---
              _buildSectionLabel("District"),
              _buildAnimatedDropdown(
                hint: "Select District",
                value: _selectedDistrict,
                items: _districts,
                onChanged: (val) => setState(() => _selectedDistrict = val),
              ),
              const SizedBox(height: 25),

              // --- 4. LAND AREA ---
              _buildSectionLabel("Land Area (Acres)"),
              _buildStyledTextField(),
              
              const SizedBox(height: 50),

              // --- SUBMIT BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    elevation: 8,
                    shadowColor: const Color(0xFF2E7D32).withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _submitForm,
                  child: Text(
                    "Go to Dashboard", 
                    style: GoogleFonts.poppins(
                      fontSize: 16, 
                      color: Colors.white, 
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1
                    )
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Provider.of<AppState>(context, listen: false).setFarmDetails(
        crop: _selectedCrop!,
        season: _selectedSeason!,
        district: _selectedDistrict!,
        area: _areaController.text,
      );

      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => const FarmerHomeScreen())
      );
    }
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 4),
      child: Text(
        text.toUpperCase(), 
        style: GoogleFonts.openSans(
          fontWeight: FontWeight.bold, 
          fontSize: 12, 
          color: Colors.grey[700],
          letterSpacing: 1.1
        )
      ),
    );
  }

  // --- CUSTOM DROPDOWN ---
  Widget _buildAnimatedDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2E7D32)),
      isExpanded: true, // IMPORTANT: Ensures text doesn't overflow
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.openSans(color: Colors.grey[400]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        fillColor: const Color(0xFFF8FAF8), 
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      // --- FIX IS HERE: selectedItemBuilder ---
      // This tells Flutter: "When selected, display THIS widget instead of the menu item"
      selectedItemBuilder: (BuildContext context) {
        return items.map<Widget>((String item) {
          return Text(
            item,
            style: GoogleFonts.openSans(
              color: const Color(0xFF1B5E20),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            overflow: TextOverflow.ellipsis,
          );
        }).toList();
      },
      // --- MENU ITEMS (Glassy Bars) ---
      items: items.asMap().entries.map((entry) {
        int idx = entry.key;
        String val = entry.value;
        
        // Alternating Colors logic
        Color bgColor = idx % 2 == 0 
            ? const Color(0xFF2E7D32).withOpacity(0.12)  
            : const Color(0xFF2E7D32).withOpacity(0.04); 

        return DropdownMenuItem(
          value: val,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor, // This background only shows in the POPUP MENU now
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(radius: 3, backgroundColor: const Color(0xFF2E7D32).withOpacity(0.6)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    val,
                    style: GoogleFonts.openSans(
                      color: const Color(0xFF1B5E20),
                      fontWeight: FontWeight.w600,
                      fontSize: 14
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? "Required field" : null,
    );
  }

  Widget _buildStyledTextField() {
    return TextFormField(
      controller: _areaController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20)),
      decoration: InputDecoration(
        hintText: "e.g. 2.5",
        hintStyle: GoogleFonts.openSans(color: Colors.grey[400], fontWeight: FontWeight.normal),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        fillColor: const Color(0xFFF8FAF8),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
        suffixIcon: const Icon(Icons.landscape, color: Colors.grey, size: 20),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return "Enter area";
        if (double.tryParse(val) == null) return "Invalid";
        return null;
      },
    );
  }
}