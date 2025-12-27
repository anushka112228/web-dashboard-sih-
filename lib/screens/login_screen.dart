import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state.dart';
import '../utils/translations.dart';
// import 'farmer/farmer_home.dart'; // No longer direct to home
import 'farmer/crop_input_screen.dart'; // NEW IMPORT
import 'admin/admin_dashboard.dart';
import 'signup_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _selectedRole = 0; 

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    String lang = appState.languageCode; 

    return Scaffold(
      // STACK for Background + Content
      body: Stack(
        children: [
          // 1. THE NEW BACKGROUND (Deep Green Gradient)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2E7D32), // Vibrant Leaf Green (Top Left)
                  Color(0xFF003300), // Very Dark Forest Green (Bottom Right)
                ],
              ),
            ),
          ),
          
          // 2. SUBTLE PATTERN
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.5), 
                radius: 1.5,
                colors: [
                  Colors.white.withOpacity(0.1), 
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // 3. THE CONTENT
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
                      // Language Dropdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.language, color: Colors.white70, size: 20),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: lang,
                            dropdownColor: const Color(0xFF1B5E20), 
                            underline: Container(),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                            style: const TextStyle(color: Colors.white),
                            items: const [
                              DropdownMenuItem(value: 'en', child: Text("English")),
                              DropdownMenuItem(value: 'hi', child: Text("हिंदी")),
                              DropdownMenuItem(value: 'or', child: Text("ଓଡିଆ")),
                            ], 
                            onChanged: (String? newLanguage) {
                              if (newLanguage != null) {
                                appState.setLanguage(newLanguage); 
                              }
                            }
                          ),
                        ],
                      ),
                      
                      const Spacer(),
          
                      // LOGO
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15), 
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white30, width: 1.5)
                        ),
                        child: const Icon(FontAwesomeIcons.leaf, size: 60, color: Colors.white),
                      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                      
                      const SizedBox(height: 20),
                      
                      // TITLE
                      Text(
                        AppTranslations.get(lang, 'title'), 
                        style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)
                      ).animate().fadeIn().slideY(begin: 0.3, end: 0),
                      
                      const Text(
                        "Empowering Farmers, Enabling Growth",
                        style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 50),
          
                      // GLASS CARD
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1), 
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2), 
                              blurRadius: 20, 
                              offset: const Offset(0, 10)
                            )
                          ]
                        ),
                        child: Column(
                          children: [
                            // ROLE TOGGLE
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2), 
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  _buildRoleTab(AppTranslations.get(lang, 'farmer'), 0),
                                  _buildRoleTab(AppTranslations.get(lang, 'official'), 1),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                
                            // INPUT
                            TextField(
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.2),
                                hintText: _selectedRole == 0 ? AppTranslations.get(lang, 'phone') : AppTranslations.get(lang, 'id'),
                                hintStyle: const TextStyle(color: Colors.white60),
                                prefixIcon: Icon(_selectedRole == 0 ? Icons.phone : Icons.badge, color: Colors.white70),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 24),
                
                            // LOGIN BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white, 
                                  foregroundColor: const Color(0xFF1B5E20), 
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  Provider.of<AppState>(context, listen: false).setUserRole(_selectedRole);
                                  if (_selectedRole == 0) {
                                    // CHANGED: Go to CropInputScreen instead of FarmerHomeScreen
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CropInputScreen()));
                                  } else {
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
                                  }
                                },
                                child: Text(
                                  AppTranslations.get(lang, 'login'), 
                                  style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.bold)
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().slideY(begin: 0.5, end: 0, delay: 300.ms, duration: 500.ms, curve: Curves.easeOutBack),
                      
                      const Spacer(),
          
                      // SIGNUP LINK
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("New User? ", style: TextStyle(color: Colors.white70)),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
                            },
                            child: const Text("Register Here", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: Colors.white)),
                          ),
                        ],
                      ).animate().fadeIn(delay: 600.ms),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTab(String title, int index) {
    bool isSelected = _selectedRole == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF1B5E20) : Colors.white70)),
        ),
      ),
    );
  }
}