import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart'; 
import '../login_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE), 
      
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80, 
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)], 
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("AgriCommand HQ", 
              style: GoogleFonts.exo2(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 1)
            ),
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                const SizedBox(width: 6),
                Text("Systems Online • Odisha Region", 
                  style: GoogleFonts.openSans(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white), 
            tooltip: "Sync Data",
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Fetching real-time data from district nodes... 📡"),
                    backgroundColor: Color(0xFF0D1B2A),
                    behavior: SnackBarBehavior.floating,
                  )
                );
            }
          ),
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: Colors.redAccent), 
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()))
          ),
          const SizedBox(width: 10),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Live Critical Alerts", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[800])),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildAlertCard("Locust Swarm", "Ganjam Sector 4", Colors.red),
                  _buildAlertCard("Heavy Rain", "Puri Coastal", Colors.orange),
                  _buildAlertCard("Low Nitrogen", "Khordha Block B", Colors.amber),
                ],
              ),
            ).animate().slideX(duration: 600.ms),

            const SizedBox(height: 25),

            // --- 2. STATS ROW (ALL CLICKABLE NOW!) ---
            Row(
              children: [
                // 1. MODEL ACCURACY -> Reports
                _buildStatCard(
                  "Model Accuracy", "87%", FontAwesomeIcons.chartLine, Colors.purple,
                  onTap: () => _showModelReport(context) 
                ),
                const SizedBox(width: 15),
                
                // 2. ACTIVE SENSORS -> IoT Grid
                _buildStatCard(
                  "Active Sensors", "1,240", FontAwesomeIcons.towerBroadcast, Colors.green,
                  onTap: () => _showSensorNetwork(context) 
                ),
                
                const SizedBox(width: 15),
                
                // 3. PENDING LOANS -> Loan List
                _buildStatCard(
                  "Pending Loans", "45", FontAwesomeIcons.fileInvoiceDollar, Colors.blue,
                  onTap: () => _showLoanList(context)
                ),
              ],
            ).animate().slideY(begin: 0.2, end: 0, delay: 200.ms),

            const SizedBox(height: 25),

            Text("Geospatial Intel", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[800])),
            const SizedBox(height: 10),
            
            Container(
              height: 350, 
              width: double.infinity, 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))],
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: const LatLng(20.2961, 85.8245), 
                          initialZoom: 13.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                            userAgentPackageName: 'com.sih.agrisense', 
                          ),
                          CircleLayer(
                            circles: [
                              CircleMarker(point: const LatLng(20.2961, 85.8245), color: Colors.green.withOpacity(0.3), borderStrokeWidth: 2, borderColor: Colors.green, useRadiusInMeter: true, radius: 1500),
                              CircleMarker(point: const LatLng(20.3100, 85.8400), color: Colors.red.withOpacity(0.3), borderStrokeWidth: 2, borderColor: Colors.red, useRadiusInMeter: true, radius: 1200),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 15, left: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem(Colors.green, "Projected High Yield"),
                            const SizedBox(height: 4),
                            _buildLegendItem(Colors.red, "Pest Risk Detected"),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ).animate().fade(delay: 300.ms),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Subsidy Approvals", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[800])),
                TextButton(onPressed: (){}, child: const Text("View All"))
              ],
            ),
            
            const FarmerRow(name: "Suresh Das", district: "Khordha", status: "High Yield", canApprove: true)
              .animate().slideX(delay: 400.ms),
            const FarmerRow(name: "Amit Nayak", district: "Puri", status: "Pest Risk", canApprove: false)
              .animate().slideX(delay: 500.ms),
            const FarmerRow(name: "Ravi Kumar", district: "Cuttack", status: "High Yield", canApprove: true)
              .animate().slideX(delay: 600.ms),
              
            const SizedBox(height: 80), 
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){}, 
        label: const Text("Broadcast Advisory", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.campaign, color: Colors.white),
        backgroundColor: const Color(0xFFD32F2F), 
      ),
    );
  }

  // --- NEW: POPUP 1 - AI MODEL REPORT ---
  void _showModelReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: 350,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("AI Model Performance", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Training Data: 10,000 samples (Khordha Region)", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            _buildBar("Precision", 0.87, Colors.purple),
            const SizedBox(height: 10),
            _buildBar("Recall (Pest Detection)", 0.92, Colors.orange),
            const SizedBox(height: 10),
            _buildBar("F1 Score", 0.89, Colors.blue),
            const Spacer(),
            const Center(child: Text("Last Trained: 2 Hours Ago", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
          ],
        ),
      )
    );
  }

  Widget _buildBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), Text("${(value*100).toInt()}%", style: TextStyle(color: color, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(value: value, minHeight: 8, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation(color)),
        )
      ],
    );
  }

  // --- NEW: POPUP 2 - LOAN LIST ---
  void _showLoanList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pending Applications", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(leading: CircleAvatar(child: Text("R")), title: Text("Ramesh Behera"), subtitle: Text("Tractor Subsidy • ₹2,00,000"), trailing: Icon(Icons.arrow_forward_ios, size: 14)),
                  ListTile(leading: CircleAvatar(child: Text("P")), title: Text("Priya Sahoo"), subtitle: Text("Seed Capital • ₹10,000"), trailing: Icon(Icons.arrow_forward_ios, size: 14)),
                  ListTile(leading: CircleAvatar(child: Text("M")), title: Text("Manoj Das"), subtitle: Text("Fertilizer Loan • ₹25,000"), trailing: Icon(Icons.arrow_forward_ios, size: 14)),
                ],
              ),
            )
          ],
        ),
      )
    );
  }

  // --- EXISTING: SENSOR NETWORK ---
  void _showSensorNetwork(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Sensor Network",
      pageBuilder: (ctx, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
            title: const Text("IoT Sensor Grid", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green)),
                child: const Row(children: [Icon(Icons.circle, size: 8, color: Colors.green), SizedBox(width: 5), Text("ONLINE", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold))]),
              )
            ],
          ),
          body: Stack(
            children: [
              FlutterMap(
                options: MapOptions(initialCenter: const LatLng(20.2961, 85.8245), initialZoom: 13.0),
                children: [
                  TileLayer(urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png', subdomains: const ['a', 'b', 'c'], userAgentPackageName: 'com.sih.agrisense'),
                  CircleLayer(circles: List.generate(50, (index) {
                      final random = Random();
                      double lat = 20.2961 + (random.nextDouble() * 0.08 - 0.04);
                      double lng = 85.8245 + (random.nextDouble() * 0.08 - 0.04);
                      return CircleMarker(point: LatLng(lat, lng), color: Colors.redAccent.withOpacity(0.6), radius: 6, borderStrokeWidth: 2, borderColor: Colors.red);
                    })),
                ],
              ),
              Positioned(
                bottom: 40, left: 20, right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [Text("1,240", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Text("Active Nodes", style: TextStyle(color: Colors.grey, fontSize: 10))]),
                      Column(children: [Text("98%", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)), Text("Uptime", style: TextStyle(color: Colors.grey, fontSize: 10))]),
                      Column(children: [Text("45ms", style: TextStyle(color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold)), Text("Latency", style: TextStyle(color: Colors.grey, fontSize: 10))]),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }
    );
  }

  // --- WIDGETS ---
  Widget _buildAlertCard(String title, String location, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      width: 160,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: color), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(Icons.warning, size: 16, color: color), const SizedBox(width: 5), Text("ALERT", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10))]), const SizedBox(height: 6), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(location, style: const TextStyle(fontSize: 12, color: Colors.black54))]),
    );
  }
  Widget _buildLegendItem(Color color, String text) {
    return Row(children: [CircleAvatar(radius: 4, backgroundColor: color), const SizedBox(width: 8), Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87))]);
  }
  Widget _buildStatCard(String label, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap, 
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]),
          child: Column(children: [Icon(icon, color: color, size: 24), const SizedBox(height: 12), Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])), Text(label, style: TextStyle(fontSize: 12, color: Colors.blueGrey[400], fontWeight: FontWeight.w500), textAlign: TextAlign.center)]),
        ),
      )
    );
  }
}

// --- SMART FARMER ROW (Same as before) ---
class FarmerRow extends StatefulWidget {
  final String name;
  final String district;
  final String status;
  final bool canApprove;

  const FarmerRow({
    super.key, 
    required this.name, 
    required this.district, 
    required this.status, 
    required this.canApprove
  });

  @override
  State<FarmerRow> createState() => _FarmerRowState();
}

class _FarmerRowState extends State<FarmerRow> {
  bool isApproved = false; 
  bool isVerified = false; 

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2))], border: Border.all(color: Colors.blueGrey[50]!)),
      child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)), child: Text(widget.name[0], style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold, fontSize: 16))), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(height: 2), Row(children: [Text(widget.district, style: const TextStyle(fontSize: 12, color: Colors.grey)), const SizedBox(width: 5), const Text("•", style: TextStyle(color: Colors.grey)), const SizedBox(width: 5), Text(widget.status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: widget.status == "Pest Risk" ? Colors.red : Colors.green))])])), if (widget.canApprove) isApproved ? _buildBadge("Approved", Colors.green, Icons.check_circle) : ElevatedButton(onPressed: () {setState(() => isApproved = true); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Subsidy Approved! ✅"), backgroundColor: Color(0xFF0D1B2A)));}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D1B2A), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)), child: const Text("Approve", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))) else isVerified ? _buildBadge("Flagged", Colors.orange, Icons.flag) : OutlinedButton(onPressed: () => _showRiskAnalysisSheet(context), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orange)), child: const Text("Verify", style: TextStyle(fontSize: 13, color: Colors.orange)))]),
    );
  }

  Widget _buildBadge(String text, Color color, IconData icon) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color)), child: Row(children: [Icon(icon, size: 16, color: color), const SizedBox(width: 5), Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12))]));
  }

  void _showRiskAnalysisSheet(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => Container(height: MediaQuery.of(context).size.height * 0.85, padding: const EdgeInsets.all(24), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Risk Analysis Report", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx))]), const Divider(), const SizedBox(height: 10), Container(height: 200, width: double.infinity, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12), image: const DecorationImage(image: NetworkImage("https://images.unsplash.com/photo-1560493676-04071c5f467b?q=80&w=1000&auto=format&fit=crop"), fit: BoxFit.cover)), child: Center(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.withOpacity(0.9), borderRadius: BorderRadius.circular(4)), child: const Text("PEST DETECTED", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))))), const SizedBox(height: 20), Row(children: [Expanded(child: _buildRiskStat("Confidence", "92%", Colors.purple)), const SizedBox(width: 10), Expanded(child: _buildRiskStat("Severity", "High", Colors.red)), const SizedBox(width: 10), Expanded(child: _buildRiskStat("Area", "1.2 Ac", Colors.blue))]), const SizedBox(height: 25), const Text("AI Analysis:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 5), const Text("Pattern recognition indicates a 92% match with 'Stem Borer' infestation signatures. Spread vector is moving North-East.", style: TextStyle(fontSize: 15, height: 1.4)), const SizedBox(height: 20), const Text("Recommended Action:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 5), const Text("Deploy Field Officer for immediate ground truthing. Issue advisory for Neem Oil application.", style: TextStyle(fontSize: 15, height: 1.4)), const SizedBox(height: 40), Row(children: [Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text("Ignore Alert"))), const SizedBox(width: 15), Expanded(child: ElevatedButton(onPressed: () {Navigator.pop(ctx); setState(() => isVerified = true); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Field Officer Dispatched! 🚔"), backgroundColor: Colors.orange));}, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text("Dispatch Officer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))])]))));
  }
  Widget _buildRiskStat(String label, String value, Color color) {
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Column(children: [Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)), Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54))]));
  }
}