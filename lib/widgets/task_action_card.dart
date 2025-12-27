import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/crop_data.dart';

class TaskActionCard extends StatelessWidget {
  final Task task;

  const TaskActionCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetailPopup(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), 
              blurRadius: 10, 
              offset: const Offset(0, 4)
            )
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: task.color.withOpacity(0.1), 
                shape: BoxShape.circle
              ),
              child: Icon(task.icon, color: task.color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: task.color.withOpacity(0.1), 
                          borderRadius: BorderRadius.circular(6)
                        ),
                        child: Text(
                          task.badge, 
                          style: TextStyle(color: task.color, fontWeight: FontWeight.bold, fontSize: 10)
                        ),
                      ),
                      if (task.isMoney) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.trending_up, size: 14, color: Colors.green)
                      ]
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(task.title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(task.subtitle, style: GoogleFonts.openSans(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showDetailPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: task.color.withOpacity(0.1),
                  child: Icon(task.icon, color: task.color),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.popupTitle, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(task.badge, style: TextStyle(color: task.color, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              task.popupBody, 
              style: GoogleFonts.openSans(fontSize: 16, height: 1.5, color: Colors.grey[800])
            ),
            const SizedBox(height: 20),
            if (task.isVerified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3))
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Text("Source: ${task.source}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Got it", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      )
    );
  }
}