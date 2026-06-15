import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../../data/portfolio_data.dart';

class SupabaseHelper {
  static final SupabaseHelper instance = SupabaseHelper._();
  SupabaseHelper._();

  bool _isInitialized = false;
  bool get isSupabaseAvailable => _isInitialized;

  // Placeholder keys - will be initialized in main.dart
  static String supabaseUrl = '';
  static String supabaseAnonKey = '';

  Future<void> initialize(String url, String anonKey) async {
    if (url.isEmpty || anonKey.isEmpty || url.startsWith('YOUR_')) {
      debugPrint("Supabase URL or Key is empty. Falling back to local data.");
      _isInitialized = false;
      return;
    }

    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      _isInitialized = true;
      debugPrint("Supabase initialized successfully.");
      
      // Run connection test to print schema issues
      if (kDebugMode) {
        _testConnection(url, anonKey);
      }
    } catch (e) {
      debugPrint("Supabase initialization error: $e. Using local fallback.");
      _isInitialized = false;
    }
  }

  Future<void> _testConnection(String url, String anonKey) async {
    try {
      final http.Response response = await http.get(
        Uri.parse('$url/rest/v1/personal_info?select=*'),
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
        },
      );
      debugPrint("================ Supabase Connection Test ================");
      debugPrint("API URL: $url/rest/v1/personal_info?select=*");
      debugPrint("HTTP Status Code: ${response.statusCode}");
      debugPrint("HTTP Response Headers: ${response.headers}");
      debugPrint("HTTP Response Body: ${response.body}");
      debugPrint("=========================================================");
    } catch (e) {
      debugPrint("================ Supabase Connection Failed ================");
      debugPrint("Error connecting to REST endpoint: $e");
      debugPrint("============================================================");
    }
  }

  // --- Upload Operations ---
  Future<String?> uploadFile({
    required String folder,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    if (!_isInitialized) return null;
    try {
      final String path = '$folder/$fileName';
      
      // Upload binary to 'portfolio_assets' bucket
      await Supabase.instance.client.storage
          .from('portfolio_assets')
          .uploadBinary(
            path,
            fileBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      // Get public URL
      final String publicUrl = Supabase.instance.client.storage
          .from('portfolio_assets')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      debugPrint("Supabase upload error: $e");
      return null;
    }
  }

  // --- Dynamic Date Formatter ---
  static String formatDateRange(String startIso, String? endIso) {
    try {
      final DateTime startDate = DateTime.parse(startIso).toLocal();
      final startStr = _formatMonthYear(startDate);
      
      if (endIso == null || endIso.trim().isEmpty) {
        return "$startStr – Present";
      }
      
      final DateTime endDate = DateTime.parse(endIso).toLocal();
      final endStr = _formatMonthYear(endDate);
      return "$startStr – $endStr";
    } catch (e) {
      debugPrint("Error formatting date range: $e");
      return "Present";
    }
  }

  static String _formatMonthYear(DateTime date) {
    final List<String> months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${months[date.month - 1]} ${date.year}";
  }

  // --- Read Operations (Gets) ---

  Future<PersonalInfo> getPersonalInfo() async {
    if (!_isInitialized) return PortfolioData.personalInfo;
    try {
      final response = await Supabase.instance.client
          .from('personal_info')
          .select()
          .maybeSingle();
      if (response != null) {
        return PersonalInfo(
          name: response['name'] ?? PortfolioData.personalInfo.name,
          shortName: response['short_name'] ?? PortfolioData.personalInfo.shortName,
          logoText: response['logo_text'] ?? PortfolioData.personalInfo.logoText,
          titles: List<String>.from(response['titles'] ?? PortfolioData.personalInfo.titles),
          email: response['email'] ?? PortfolioData.personalInfo.email,
          phone: response['phone'] ?? PortfolioData.personalInfo.phone,
          location: response['location'] ?? PortfolioData.personalInfo.location,
          aboutMe: response['about_me'] ?? PortfolioData.personalInfo.aboutMe,
          github: response['github'] ?? PortfolioData.personalInfo.github,
          linkedin: response['linkedin'] ?? PortfolioData.personalInfo.linkedin,
          cvUrl: response['cv_url'] ?? PortfolioData.personalInfo.cvUrl,
          imageUrl: response['image_url'] ?? PortfolioData.personalInfo.imageUrl,
        );
      }
    } catch (e) {
      debugPrint("Error fetching personal_info: $e");
    }
    return PortfolioData.personalInfo;
  }

  Future<List<SkillCategory>> getSkills() async {
    if (!_isInitialized) return PortfolioData.skills;
    try {
      final List<dynamic> data = await Supabase.instance.client
          .from('skills')
          .select()
          .order('display_order', ascending: true);
      if (data.isNotEmpty) {
        return data.map((item) {
          return SkillCategory(
            name: item['category_name'] ?? '',
            skills: List<String>.from(item['skills_list'] ?? []),
          );
        }).toList();
      }
    } catch (e) {
      debugPrint("Error fetching skills: $e");
    }
    return PortfolioData.skills;
  }

  Future<List<ExperienceItem>> getExperiences() async {
    if (!_isInitialized) {
      final combined = <ExperienceItem>[];
      combined.addAll(PortfolioData.experiences);
      combined.addAll(PortfolioData.education);
      return combined;
    }
    try {
      final List<dynamic> data = await Supabase.instance.client
          .from('experiences')
          .select()
          .order('display_order', ascending: true);
      if (data.isNotEmpty) {
        return data.map((item) {
          final startIso = item['start_date'] as String;
          final endIso = item['end_date'] as String?;
          
          return ExperienceItem(
            company: item['company'] ?? '',
            role: item['role'] ?? '',
            duration: formatDateRange(startIso, endIso),
            location: item['location'] ?? '',
            bullets: [item['description'] ?? ''],
            isEducation: item['is_education'] ?? false,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint("Error fetching experiences: $e");
    }
    final combined = <ExperienceItem>[];
    combined.addAll(PortfolioData.experiences);
    combined.addAll(PortfolioData.education);
    return combined;
  }

  Future<List<ProjectItem>> getProjects() async {
    if (!_isInitialized) return PortfolioData.projects;
    try {
      final List<dynamic> data = await Supabase.instance.client
          .from('projects')
          .select()
          .order('display_order', ascending: true);
      if (data.isNotEmpty) {
        return data.map((item) {
          final List<dynamic> linksRaw = item['links'] ?? [];
          final String? git = _findLink(linksRaw, 'github');
          final String? live = _findLink(linksRaw, 'live');

          return ProjectItem(
            name: item['name'] ?? '',
            subtitle: item['subtitle'] ?? '',
            description: item['description'] ?? '',
            bulletPoints: List<String>.from(item['features'] ?? []),
            techStack: List<String>.from(item['tech_stack'] ?? []),
            liveLink: live,
            githubLink: git,
            screenshots: List<String>.from(item['screenshots'] ?? []),
          );
        }).toList();
      }
    } catch (e) {
      debugPrint("Error fetching projects: $e");
    }
    return PortfolioData.projects;
  }

  String? _findLink(List<dynamic> links, String type) {
    for (var link in links) {
      if (link is Map && link['type'] == type) {
        return link['url'] as String?;
      }
    }
    return null;
  }

  // --- Write Operations (Saves & Deletes) ---

  Future<void> savePersonalInfo(PersonalInfo info) async {
    if (!_isInitialized) return;
    await Supabase.instance.client.from('personal_info').upsert({
      'id': 1, // Only 1 doc
      'name': info.name,
      'short_name': info.shortName,
      'logo_text': info.logoText,
      'titles': info.titles,
      'email': info.email,
      'phone': info.phone,
      'location': info.location,
      'about_me': info.aboutMe,
      'github': info.github,
      'linkedin': info.linkedin,
      'cv_url': info.cvUrl,
      'image_url': info.imageUrl,
    });
  }

  Future<void> saveSkill(int? id, String categoryName, List<String> skills, int order) async {
    if (!_isInitialized) return;
    final payload = {
      'category_name': categoryName,
      'skills_list': skills,
      'display_order': order,
    };
    if (id != null) {
      await Supabase.instance.client.from('skills').update(payload).eq('id', id);
    } else {
      await Supabase.instance.client.from('skills').insert(payload);
    }
  }

  Future<void> deleteSkill(int id) async {
    if (!_isInitialized) return;
    await Supabase.instance.client.from('skills').delete().eq('id', id);
  }

  Future<void> saveExperience({
    int? id,
    required String company,
    required String role,
    required String startIso,
    required String? endIso,
    required String location,
    required String description,
    required bool isEducation,
    required int order,
  }) async {
    if (!_isInitialized) return;
    final payload = {
      'company': company,
      'role': role,
      'start_date': startIso,
      'end_date': endIso,
      'location': location,
      'description': description,
      'is_education': isEducation,
      'display_order': order,
    };
    if (id != null) {
      await Supabase.instance.client.from('experiences').update(payload).eq('id', id);
    } else {
      await Supabase.instance.client.from('experiences').insert(payload);
    }
  }

  Future<void> deleteExperience(int id) async {
    if (!_isInitialized) return;
    await Supabase.instance.client.from('experiences').delete().eq('id', id);
  }

  Future<void> saveProject({
    int? id,
    required String name,
    required String subtitle,
    required String description,
    required List<String> features,
    required List<String> techStack,
    required List<Map<String, dynamic>> links,
    required List<String> screenshots,
    required int order,
  }) async {
    if (!_isInitialized) return;
    final payload = {
      'name': name,
      'subtitle': subtitle,
      'description': description,
      'features': features,
      'tech_stack': techStack,
      'links': links,
      'screenshots': screenshots,
      'display_order': order,
    };
    if (id != null) {
      await Supabase.instance.client.from('projects').update(payload).eq('id', id);
    } else {
      await Supabase.instance.client.from('projects').insert(payload);
    }
  }

  Future<void> deleteProject(int id) async {
    if (!_isInitialized) return;
    await Supabase.instance.client.from('projects').delete().eq('id', id);
  }
}
