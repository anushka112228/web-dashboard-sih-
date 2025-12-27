// Needed for FileImage
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import '../data/crop_data.dart';
import '../utils/translations.dart';
import '../screens/login_screen.dart';
import '../screens/farmer/edit_profile_screen.dart'; // <--- IMPORT THIS

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final lang = appState.languageCode;
    
    // FETCH DYNAMIC DATA
    final CropInfo cropInfo = CropData.get(appState.selectedCrop);

    return Drawer(
      child: Column(
        children: [
          // 1. HEADER (NOW CLICKABLE!)
          GestureDetector(
            onTap: () {
              // Close the drawer first
              Navigator.pop(context);
              // Navigate to Edit Profile
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const EditProfileScreen())
              );
            },
            child: UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Row(
                children: [
                  Text(
                    appState.farmerName, 
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(width: 8),
                  // VISUAL CUE: PENCIL ICON
                  const Icon(Icons.edit, color: Colors.white70, size: 16),
                ],
              ),
              accountEmail: Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text("${appState.district} • ${appState.season}", style: const TextStyle(color: Colors.white70)),
                ],
              ),
              currentAccountPicture: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  // Display image if available
                  image: appState.profileImage != null 
                      ? DecorationImage(
                          image: FileImage(appState.profileImage!), 
                          fit: BoxFit.cover
                        )
                      : null,
                ),
                child: appState.profileImage == null 
                    ? const Icon(Icons.person, color: Color(0xFF2E7D32), size: 40) 
                    : null,
              ),
              // Arrow icon on the right to show it's clickable
              otherAccountsPictures: [
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
                  onPressed: () {
                     Navigator.pop(context);
                     Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                  },
                )
              ],
            ),
          ),

          // 2. LIST ITEMS
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // --- SEGMENT 1: MY FARM ---
                _buildSectionHeader(AppTranslations.get(lang, 'my_farm')),
                
                _buildDrawerItem(
                  icon: FontAwesomeIcons.seedling,
                  title: AppTranslations.get(lang, 'crop_details'),
                  onTap: () => _showCropDetailsPopup(context, appState, cropInfo),
                ),
                
                _buildDrawerItem(
                  icon: FontAwesomeIcons.flask,
                  title: AppTranslations.get(lang, 'soil_card'),
                  onTap: () => _showSoilHealthPopup(context, cropInfo.soilHealth),
                ),

                const Divider(),

                // --- SEGMENT 2: SERVICES ---
                _buildSectionHeader(AppTranslations.get(lang, 'services')),
                
                _buildDrawerItem(
                  icon: FontAwesomeIcons.indianRupeeSign,
                  title: AppTranslations.get(lang, 'mandi'),
                  onTap: () => _showMandiPricesPopup(context, cropInfo),
                ),

                const Divider(),

                // --- SEGMENT 3: SETTINGS / LANGUAGE ---
                _buildSectionHeader(AppTranslations.get(lang, 'settings')),
                
                ExpansionTile(
                  leading: const Icon(Icons.language, color: Colors.grey),
                  title: Text(AppTranslations.get(lang, 'change_lang'), style: GoogleFonts.openSans(fontWeight: FontWeight.w600)),
                  children: [
                    _buildLanguageItem(context, 'en', 'English'),
                    _buildLanguageItem(context, 'hi', 'हिंदी'),
                    _buildLanguageItem(context, 'or', 'ଓଡିଆ'),
                  ],
                ),

                const SizedBox(height: 20),
                
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(AppTranslations.get(lang, 'logout'), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                ),
              ],
            ),
          ),
          
          // FOOTER
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("App Version 1.0.2", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // --- POPUP LOGIC ---

  void _showCropDetailsPopup(BuildContext context, AppState state, CropInfo crop) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Crop Details", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                Chip(label: Text(crop.name), backgroundColor: Colors.green[50], labelStyle: const TextStyle(color: Colors.green)),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.calendar_today, "Sowing Date", crop.sowingDate),
            _buildDetailRow(Icons.timeline, "Current Stage", crop.stage),
            _buildDetailRow(Icons.event, "Expected Harvest", crop.harvestDate),
            _buildDetailRow(Icons.landscape, "Total Land", state.landSize),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                child: const Text("Close", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showSoilHealthPopup(BuildContext context, SoilHealth soil) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(FontAwesomeIcons.flask, color: Colors.brown),
            const SizedBox(width: 10),
            Text("Soil Health Card", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNutrientBar("Nitrogen (N)", soil.nitrogen),
            const SizedBox(height: 15),
            _buildNutrientBar("Phosphorus (P)", soil.phosphorus),
            const SizedBox(height: 15),
            _buildNutrientBar("Potassium (K)", soil.potassium),
            const SizedBox(height: 15),
            Divider(color: Colors.grey[300]),
            Text("Soil pH: ${soil.pH}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK", style: TextStyle(color: Colors.brown)))
        ],
      ),
    );
  }

  void _showMandiPricesPopup(BuildContext context, CropInfo crop) {
    final bool isUp = crop.marketData.trend == "Rising";
    final bool isStable = crop.marketData.trend == "Stable";
    final Color trendColor = isUp ? Colors.green : (isStable ? Colors.grey : Colors.red);
    final IconData trendIcon = isUp ? Icons.trending_up : (isStable ? Icons.remove : Icons.trending_down);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        height: 250,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text("Mandi Prices", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text("Regional Average • Live Update", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("₹${crop.marketData.price}", style: GoogleFonts.openSans(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(width: 10),
                Column(
                  children: [
                    Icon(trendIcon, color: trendColor, size: 30),
                    Text(crop.marketData.trend, style: TextStyle(color: trendColor, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 10),
            Text("Per Quintal", style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
      title: Text(title, style: GoogleFonts.openSans(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNutrientBar(String label, String level) {
    Color color = level == "Low" ? Colors.red : (level == "Optimal" || level == "High" ? Colors.green : Colors.orange);
    double percent = level == "Low" ? 0.3 : (level == "Medium" ? 0.6 : 0.9);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(level, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 10,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(color),
          ),
        )
      ],
    );
  }

  Widget _buildLanguageItem(BuildContext context, String code, String name) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 50),
      title: Text(name),
      trailing: Provider.of<AppState>(context).languageCode == code 
          ? const Icon(Icons.check, color: Colors.green) 
          : null,
      onTap: () {
        Provider.of<AppState>(context, listen: false).setLanguage(code);
        Navigator.pop(context); // Close drawer to refresh UI visually
      },
    );
  }
}