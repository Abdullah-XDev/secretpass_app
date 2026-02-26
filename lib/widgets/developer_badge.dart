import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DeveloperBadge extends StatelessWidget {
  const DeveloperBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border(
          top: BorderSide(color: const Color(0xFFFFB300).withOpacity(0.15)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left decorative line
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xFFFFB300).withOpacity(0.35),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Amber dot icon
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(Icons.code_rounded, color: Colors.black, size: 13),
          ),
          const SizedBox(width: 8),
          // Developer name
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Developed by  ',
                  style: GoogleFonts.tajawal(
                    color: Colors.white24,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: 'Eng. Abdullah Esh',
                  style: GoogleFonts.playfairDisplay(
                    color: const Color(0xFFFFB300),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Right decorative line
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFB300).withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
