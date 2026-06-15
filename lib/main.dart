import 'package:flutter/material.dart';

import 'core/services/supabase_helper.dart';
import 'core/theme/app_theme.dart';
import 'data/portfolio_data.dart';
import 'features/admin/presentation/pages/admin_page.dart';
import 'features/portfolio/presentation/pages/portfolio_home_page.dart';

// --- DATABASE CONFIGURATION ---
// Set your Supabase details here. You can find these in your Supabase Settings -> API tab.
const String supabaseUrl = 'https://dpausezkxzhhnyhtbkfu.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRwYXVzZXpreHpoaG55aHRia2Z1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE1MjQ2ODAsImV4cCI6MjA5NzEwMDY4MH0.dZcXOGOvf7LYhKC8oYccn2WQwpRLt1Ha_tlXTMc8b-g';

// --- ADMIN TOGGLE CONFIGURATION ---
// Set to true on your local machine to launch the Admin Data Editor.
// Set to false when compiling the production website for deploy.
const bool showAdminPanel = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (gracefully falls back to local data if keys are not filled)
  await SupabaseHelper.instance.initialize(supabaseUrl, supabaseAnonKey);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = true;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: PortfolioData.personalInfo.name,
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: showAdminPanel
          ? const AdminPage()
          : PortfolioHomePage(
              isDarkMode: _isDarkMode,
              onThemeToggle: _toggleTheme,
            ),
    );
  }
}
