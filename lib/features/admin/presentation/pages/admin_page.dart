import 'package:flutter/material.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/services/supabase_helper.dart';
import '../widgets/personal_info_tab.dart';
import '../widgets/skills_tab.dart';
import '../widgets/journey_tab.dart';
import '../widgets/projects_tab.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!SupabaseHelper.instance.isSupabaseAvailable) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orangeAccent),
                const SizedBox(height: 16),
                Text(
                  "Supabase Connection is Offline",
                  style: AppTextStyles.cardTitle(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please paste your Supabase URL & Keys inside lib/main.dart first, then run local Admin dashboard to update data.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Portfolio Local Admin Console"),
          backgroundColor: theme.scaffoldBackgroundColor,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: "Personal Info"),
              Tab(icon: Icon(Icons.code), text: "Skills"),
              Tab(icon: Icon(Icons.history), text: "Journey"),
              Tab(icon: Icon(Icons.work), text: "Projects"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PersonalInfoTab(),
            SkillsTab(),
            JourneyTab(),
            ProjectsTab(),
          ],
        ),
      ),
    );
  }
}
