import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, dynamic>> _messages = [
    {"isUser": false, "text": "Hello! I am your Agri-Assistant. 🤖 Ask me about pest control, weather, or crop prices!"}
  ];

  bool _isTyping = false;

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text;
    setState(() {
      _messages.add({"isUser": true, "text": userText});
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add({"isUser": false, "text": _getMockAIResponse(userText)});
      });
      _scrollToBottom();
    });
  }

  String _getMockAIResponse(String input) {
    input = input.toLowerCase();
    if (input.contains("weather") || input.contains("rain")) {
      return "Forecast shows heavy rain in Khordha district tomorrow. 🌧️ Ensure proper drainage!";
    } else if (input.contains("pest") || input.contains("bug")) {
      return "For Stem Borers, apply Neem Oil immediately. Consult the 'Quick Tools' section for chemical advice. 🐛";
    } else if (input.contains("price") || input.contains("rate")) {
      return "Current Mandi rates: ₹2,100/Qt. Trend is stable. 💰";
    } else {
      return "I'm still learning! Try asking about 'Weather', 'Pests', or 'Prices'.";
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(FontAwesomeIcons.robot, color: Colors.green, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Agri-Bot", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                const Text("Online", style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg['isUser'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: msg['isUser'] ? const Color(0xFF2E7D32) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [if (!msg['isUser']) const BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))]
                    ),
                    child: Text(msg['text'], style: GoogleFonts.openSans(color: msg['isUser'] ? Colors.white : Colors.black87, fontSize: 15)),
                  ),
                );
              },
            ),
          ),
          if (_isTyping) const Padding(padding: EdgeInsets.all(20), child: Text("Agri-Bot is typing...", style: TextStyle(color: Colors.grey))),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask about your crop...",
                      filled: true,
                      fillColor: const Color(0xFFF4F7FE),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: const CircleAvatar(radius: 24, backgroundColor: Color(0xFF2E7D32), child: Icon(Icons.send, color: Colors.white, size: 20)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}