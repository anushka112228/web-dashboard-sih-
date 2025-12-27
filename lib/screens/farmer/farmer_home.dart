import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/app_state.dart';
import '../../utils/translations.dart';
import '../../data/crop_data.dart';
import '../../widgets/quick_tools_widget.dart';
import '../../widgets/task_action_card.dart';
import '../../widgets/yield_graph.dart';
import '../../widgets/sidebar_drawer.dart'; // NEW IMPORT
// import '../login_screen.dart'; // Removed as logout is in sidebar now

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final lang = appState.languageCode;
    
    // 1. GET DATA (Simulating API Call)
    final CropInfo cropInfo = CropData.get(appState.selectedCrop);

    // 2. DYNAMIC HEALTH LOGIC (Visuals change based on backend data)
    final bool isStressed = !cropInfo.isHealthy;
    final Color healthColor = isStressed ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32);
    final Color healthBg = isStressed ? Colors.red[50]! : Colors.green[50]!;
    final IconData healthIcon = isStressed ? FontAwesomeIcons.triangleExclamation : FontAwesomeIcons.leaf;
    final String healthTitle = isStressed ? "Stress Detected" : "Healthy Crop";
    final String healthSubtitle = isStressed ? cropInfo.healthIssue : cropInfo.days;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(appState, cropInfo),
      
      // --- SIDEBAR DRAWER ---
      drawer: const SidebarDrawer(), // Using the new separate file
      
      // --- AI VOICE ASSISTANT BUTTON ---
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showListeningModal(context),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 5,
        icon: const Icon(Icons.mic, color: Colors.white),
        label: Text("Ask AI Assistant", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ).animate().scale(delay: 1.seconds, curve: Curves.elasticOut),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CROP HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Current Season", style: GoogleFonts.openSans(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                    Text(appState.selectedCrop, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange[200]!)),
                  child: Text(cropInfo.stage, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange[800])),
                )
              ],
            ).animate().fadeIn().slideX(),

            const SizedBox(height: 20),

            // --- DYNAMIC HEALTH CARD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 25, backgroundColor: healthBg, child: Icon(healthIcon, color: healthColor)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(healthTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: healthColor)),
                            Text(healthSubtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Icon(isStressed ? Icons.warning_amber_rounded : Icons.check_circle, color: healthColor, size: 28),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Progress Bar changes color based on stress
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: cropInfo.progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey[100],
                      valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                    ),
                  )
                ],
              ),
            ).animate().slideY(begin: 0.2, end: 0, delay: 200.ms),

            const SizedBox(height: 25),
            const QuickToolsWidget().animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 25),

            Text(AppTranslations.get(lang, 'do_today'), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 12),

            if (cropInfo.tasks.isEmpty)
              const Center(child: Text("No tasks today! Relax. 🍵"))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cropInfo.tasks.length,
                itemBuilder: (context, index) {
                  return TaskActionCard(task: cropInfo.tasks[index])
                      .animate().slideX(delay: (400 + (index * 100)).ms);
                },
              ),

            const SizedBox(height: 25),

            // Yield Graph
            YieldGraphWidget(history: cropInfo.yieldHistory, prediction: cropInfo.predictedYield)
                .animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }

  // --- DYNAMIC APP BAR (Handles Weather) ---
  AppBar _buildAppBar(AppState appState, CropInfo cropInfo) {
    IconData weatherIcon;
    Color weatherColor;
    Color weatherBg;
    String weatherText;

    if (cropInfo.weatherType == "Rainy") {
      weatherIcon = FontAwesomeIcons.cloudShowersHeavy;
      weatherColor = Colors.red;
      weatherBg = Colors.red[50]!;
      weatherText = "Heavy Rain";
    } else if (cropInfo.weatherType == "Cloudy") {
      weatherIcon = FontAwesomeIcons.cloud;
      weatherColor = Colors.indigo;
      weatherBg = Colors.indigo[50]!;
      weatherText = "Cloudy";
    } else {
      weatherIcon = FontAwesomeIcons.sun;
      weatherColor = Colors.orange;
      weatherBg = Colors.orange[50]!;
      weatherText = "Sunny 32°C";
    }

    return AppBar(
      elevation: 0, backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hey, ${appState.farmerName.split(' ')[0]}", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
          Row(children: [Icon(Icons.cloud_done, size: 12, color: Colors.green), const SizedBox(width: 4), Text("Online Mode", style: const TextStyle(fontSize: 12, color: Colors.grey))]),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: weatherBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: weatherColor.withOpacity(0.3))),
          child: Row(children: [Icon(weatherIcon, size: 14, color: weatherColor), const SizedBox(width: 8), Text(weatherText, style: TextStyle(fontWeight: FontWeight.bold, color: weatherColor, fontSize: 12))]),
        )
      ],
    );
  }

  void _showListeningModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: 250,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Listening...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 20),
            // Pulsing Animation Widget
            const AvatarGlowWidget(),
            const SizedBox(height: 20),
            Text("Try saying: 'Is my crop healthy?'", style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// Visual Widget for the AI Listening Pulse
class AvatarGlowWidget extends StatefulWidget {
  const AvatarGlowWidget({super.key});
  @override
  State<AvatarGlowWidget> createState() => _AvatarGlowWidgetState();
}

class _AvatarGlowWidgetState extends State<AvatarGlowWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.2).animate(_controller),
      child: Container(
        height: 80, width: 80,
        decoration: BoxDecoration(color: const Color(0xFF2E7D32).withOpacity(0.2), shape: BoxShape.circle),
        child: const Center(
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFF2E7D32),
            child: Icon(Icons.mic, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}