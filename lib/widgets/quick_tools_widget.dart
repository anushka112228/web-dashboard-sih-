import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/translations.dart';

class QuickToolsWidget extends StatelessWidget {
  const QuickToolsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppState>(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTranslations.get(lang, 'quick_tools'), 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 12),
        
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildToolCard(context, FontAwesomeIcons.camera, AppTranslations.get(lang, 'scan_crop'), Colors.purple, () => _openCameraSimulation(context)),
              _buildToolCard(context, FontAwesomeIcons.phone, AppTranslations.get(lang, 'helpline'), Colors.green, () => _callHelpline(context)),
              _buildToolCard(context, FontAwesomeIcons.fileContract, AppTranslations.get(lang, 'schemes_tool'), Colors.blue, () => _showSchemesList(context)),
              _buildToolCard(context, FontAwesomeIcons.newspaper, AppTranslations.get(lang, 'news'), Colors.orange, () => _showNewsToast(context)),
              _buildToolCard(context, FontAwesomeIcons.cloudRain, AppTranslations.get(lang, 'weather_map'), Colors.indigo, () {}),
            ],
          ),
        ),
      ],
    );
  }

  // --- POPUP HELPERS ---

  void _openCameraSimulation(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(backgroundColor: Colors.black87, title: const Text("AI Crop Doctor", style: TextStyle(color: Colors.white)), content: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.center_focus_weak, size: 80, color: Colors.white), const Text("Simulating Camera...", style: TextStyle(color: Colors.white70)), ElevatedButton(onPressed: () {Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Image Captured! Analyzing..."), backgroundColor: Colors.green));}, child: const Text("Capture Photo"))])));
  }

  void _callHelpline(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Row(children: [Icon(Icons.phone_in_talk, color: Colors.white), SizedBox(width: 10), Text("Dialing Kisan Call Center...")]), backgroundColor: Colors.green, duration: Duration(seconds: 3)));
  }

  void _showSchemesList(BuildContext context) {
    final lang = Provider.of<AppState>(context, listen: false).languageCode;
    
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Translated Title
            Text(AppTranslations.get(lang, 'schemes'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Translated List Items
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(AppTranslations.get(lang, 'kalia_scheme')),
              subtitle: Text("${AppTranslations.get(lang, 'status_active')} - ₹5,000 Credited"),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.orange),
              title: Text(AppTranslations.get(lang, 'pm_kisan')),
              subtitle: Text(AppTranslations.get(lang, 'action_kyc')),
            ),
            ListTile(
              leading: const Icon(Icons.hourglass_empty, color: Colors.grey),
              title: Text(AppTranslations.get(lang, 'machinery_subsidy')),
              subtitle: Text(AppTranslations.get(lang, 'status_pending')),
            ),
          ],
        ),
      )
    );
  }

  void _showNewsToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fetching latest market news...")));
  }

  Widget _buildToolCard(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!), boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))]),
        child: Column(
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20)),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}