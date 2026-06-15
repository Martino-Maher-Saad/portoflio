import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Base Font Family is Outfit
  static TextStyle outfit({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Hero Section Title (Large)
  static TextStyle heroName({required Color color, required bool isMobile}) {
    return outfit(
      fontSize: isMobile ? 36.0 : 56.0,
      fontWeight: FontWeight.w900,
      color: color,
      height: 1.1,
    );
  }

  // Section Headers (About, Skills, Experience, Contact, Projects)
  static TextStyle sectionHeader({required Color color, required bool isMobile}) {
    return outfit(
      fontSize: isMobile ? 32.0 : 44.0,
      fontWeight: FontWeight.w900,
      color: color,
    );
  }

  // Section Subtitles (Experience, Education headings)
  static TextStyle sectionSubHeader({required Color color, required bool isMobile}) {
    return outfit(
      fontSize: isMobile ? 22.0 : 26.0,
      fontWeight: FontWeight.w900,
      color: color,
    );
  }

  // Card Titles (e.g. Skill Category, Project Name, Timeline Role)
  static TextStyle cardTitle({required Color color}) {
    return outfit(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  // Paragraph Body Texts
  static TextStyle body({required Color color}) {
    return outfit(
      fontSize: 16.0,
      color: color,
      height: 1.6,
    );
  }

  // Card details/bullets subtext
  static TextStyle cardBody({required Color color}) {
    return outfit(
      fontSize: 14.0,
      color: color,
      height: 1.5,
    );
  }

  // Small labels or tags
  static TextStyle tag({required Color color}) {
    return outfit(
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }
}
