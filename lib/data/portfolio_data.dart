class PersonalInfo {
  final String name;
  final String shortName;
  final String logoText;
  final List<String> titles;
  final String email;
  final String phone;
  final String location;
  final String aboutMe;
  final String github;
  final String linkedin;
  final String cvUrl;
  final String imageUrl;

  const PersonalInfo({
    required this.name,
    required this.shortName,
    required this.logoText,
    required this.titles,
    required this.email,
    required this.phone,
    required this.location,
    required this.aboutMe,
    required this.github,
    required this.linkedin,
    required this.cvUrl,
    required this.imageUrl,
  });
}

class SkillCategory {
  final String name;
  final List<String> skills;

  const SkillCategory({required this.name, required this.skills});
}

class ExperienceItem {
  final String company;
  final String role;
  final String duration;
  final String location;
  final List<String> bullets;
  final bool isEducation;

  const ExperienceItem({
    required this.company,
    required this.role,
    required this.duration,
    required this.location,
    required this.bullets,
    this.isEducation = false,
  });
}

class ProjectItem {
  final String name;
  final String subtitle;
  final String description;
  final List<String> bulletPoints;
  final List<String> techStack;
  final String? liveLink;
  final String? githubLink;
  final List<String> screenshots;

  const ProjectItem({
    required this.name,
    required this.subtitle,
    required this.description,
    required this.bulletPoints,
    required this.techStack,
    this.liveLink,
    this.githubLink,
    this.screenshots = const [],
  });
}

// Portfolio Data Instance
class PortfolioData {
  static const PersonalInfo personalInfo = PersonalInfo(
    name: "Martino Maher Saad",
    shortName: "Martino Saad",
    logoText: "MMS.",
    titles: [
      "Software Engineer",
      "Flutter Developer",
      "AI Automation Specialist",
    ],
    email: "martinomaher@gmail.com",
    phone: "01007989538",
    location: "Giza, Egypt",
    aboutMe:
        "Software Engineer specializing in building high-performance mobile applications and scalable business ecosystems within the Flutter ecosystem. Expert in architecting end-to-end products using Supabase, Firebase, and custom PHP/ MySQL backends. I possess a strong background in enhancing application logic through AI-driven automation using n8n and Flowise.",
    github: "https://github.com/Martino-Maher-Saad",
    linkedin: "https://www.linkedin.com/in/Martino-M-Saad",
    cvUrl:
        "https://flowcv.com/resume/4rrm09qks4n0",
    imageUrl: "profile_image.png", // Default beautiful portrait placeholder
  );

  static const List<SkillCategory> skills = [
    SkillCategory(
      name: "Mobile Development",
      skills: ["Flutter", "Dart", "Responsive & Adaptive UI"],
    ),
    SkillCategory(
      name: "Architecture & Patterns",
      skills: [
        "Clean Architecture",
        "Feature-First Architecture",
        "MVVM",
        "SOLID Principles",
      ],
    ),
    SkillCategory(name: "State Management", skills: ["BLoC / Cubit", "GetX"]),
    SkillCategory(
      name: "Backend & APIs",
      skills: [
        "Supabase",
        "RESTful APIs",
        "Dio",
        "Firebase",
        "PostgreSQL (pgvector, Indexing, Triggers)",
      ],
    ),
    SkillCategory(
      name: "Programming Languages",
      skills: ["Dart", "Python", "PHP", "SQL", "C++", "Java"],
    ),
    SkillCategory(
      name: "Tools",
      skills: ["Git / GitHub", "Postman", "n8n", "Flowise"],
    ),
    SkillCategory(
      name: "AI & Automation",
      skills: [
        "Prompt Engineering",
        "AI Agents Development",
        "PyTorch & BioBERT",
      ],
    ),
  ];

  static const List<ExperienceItem> experiences = [
    ExperienceItem(
      company: "Retaj Real Estate",
      role: "Software Engineer | Flutter Developer",
      duration: "11/2025 – Present",
      location: "Nasr City, Cairo, Egypt",
      bullets: [
        "Ecosystem Architecture: Engineered a cross-platform digital ecosystem (Web CRM, Staff App, and Client App) using Flutter and a unified Supabase/ PostgreSQL backend.",
        "AI Semantic Search: Integrated Google Gemini Embeddings with PostgreSQL (pgvector) to enable natural language property discovery via high-accuracy cosine similarity.",
        "Performance Optimization: Developed a 'Surgical Update' pattern using BLoC/ Cubit for in-memory state mutations, eliminating redundant API calls and reducing latency.",
        "Advanced Data Modeling: Designed an optimized PostgreSQL schema featuring Role-Based Access Control (RBAC), full-text search vectors (tsvector), and efficient pagination for high-volume property inventories.",
        "Media Management: Implemented secure cloud storage with client-side image compression and aggressive caching (cached_network_image) to minimize bandwidth costs.",
      ],
    ),
    ExperienceItem(
      company: "Octobot",
      role: "AI Automation & Prompt Engineer",
      duration: "02/2026 – Present",
      location: "Online / Remote",
      bullets: [
        "Agentic Workflows: Designing and deploying autonomous AI agents using Flowise and n8n to automate complex business logic and data pipelines.",
        "Prompt Engineering: Developing specialized system message templates and prompt architectures to optimize LLM accuracy and response consistency.",
      ],
    ),
    ExperienceItem(
      company: "Instant Company",
      role: "AI & Data Science Intern",
      duration: "07/2025 – 08/2025",
      location: "Dokki City, Giza, Egypt",
      bullets: [
        "Performed data preprocessing, feature engineering, and model validation.",
        "Collaborated with cross-functional teams to deploy AI-powered prototypes.",
        "Built and evaluated machine learning models for predictive analytics.",
        "Developed Medical Chatbot for Disease Diagnosis using BioBERT & PyTorch, predicting diseases from symptom descriptions with 88% accuracy.",
      ],
    ),
  ];

  static const List<ExperienceItem> education = [
    ExperienceItem(
      company: "Fayoum University",
      role: "B.S.E. in Computers and Systems Engineering",
      duration: "09/2020 – 07/2025",
      location: "Fayoum, Egypt",
      isEducation: true,
      bullets: [
        "Accumulative Grade: Very Good",
        "Graduation project grade: Excellent",
        "Military Service: Exempted",
      ],
    ),
  ];

  static const List<ProjectItem> projects = [
    ProjectItem(
      name: "Sala",
      subtitle: "Full-Stack E-Commerce Marketplace",
      description:
          "A complete localized e-commerce solution featuring a Flutter frontend and custom PHP/MySQL backend.",
      bulletPoints: [
        "Engineered Flutter frontend and custom PHP/ MySQL backend, managing relational structures for users, products, and order flows.",
        "Developed a multi-stage authentication system featuring OTP-based verification, password recovery, and middleware session guards via GetX.",
        "Implemented a dual-database caching strategy using SQLite for offline capability and MySQL for cloud synchronizations.",
        "Fully localized experience (Arabic/English) with Lottie/SVG graphics and real-time FCM tracking.",
      ],
      techStack: [
        "Flutter",
        "Dart",
        "PHP",
        "MySQL",
        "GetX",
        "SQLite",
        "Firebase FCM",
      ],
      liveLink: "https://github.com/Martino-Maher-Saad/Sala",
      githubLink: "https://github.com/Martino-Maher-Saad/Sala",
    ),
    ProjectItem(
      name: "Handly",
      subtitle: "Premium Handcrafted Marketplace",
      description:
          "A gorgeous handcrafted product marketplace optimized using Neumorphic Design principles.",
      bulletPoints: [
        "Engineered tactile marketplace utilizing Neumorphic Design principles and flutter_screenutil for pixel-perfect cross-platform adaptability.",
        "Implemented Feature-Based Clean Architecture and custom BLoC shell navigation to maintain complex tab-states.",
        "Integrated Supabase auth and optimized a custom multi-category filtering search engine.",
      ],
      techStack: ["Flutter", "Dart", "BLoC", "Supabase", "Neumorphic Design"],
      liveLink: "https://github.com/Martino-Maher-Saad/Handly",
      githubLink: "https://github.com/Martino-Maher-Saad/Handly",
    ),
    ProjectItem(
      name: "Hungry App",
      subtitle: "Food Delivery Solution",
      description:
          "A high-performance food delivery mobile client following the repository pattern.",
      bulletPoints: [
        "Structured codebase using Feature-First Architecture and Repository Pattern, decoupling UI logic from APIs.",
        "Developed centralized Dio client with JWT token auto-refresh, unified interceptor error handling, and exception mapping.",
        "Designed SliverAppBar menus with dynamic category filtering and fluid micro-animations.",
        "Built local real-time cart synchronization minimizing memory footprint.",
      ],
      techStack: ["Flutter", "Dart", "Dio", "Repository Pattern", "Slivers"],
      liveLink: "https://github.com/Martino-Maher-Saad/HungryApp",
      githubLink: "https://github.com/Martino-Maher-Saad/HungryApp",
    ),
    ProjectItem(
      name: "Medical Chatbot",
      subtitle: "Disease Diagnosis System",
      description:
          "An AI diagnostics assistant built with deep learning models predicting diseases with 88% accuracy.",
      bulletPoints: [
        "Developed symptom-based disease diagnostics chatbot using PyTorch and BioBERT model.",
        "Achieved 88% prediction accuracy on multi-label classification of complex disease profiles.",
      ],
      techStack: ["Python", "PyTorch", "BioBERT", "AI & NLP"],
      liveLink: "https://github.com/Martino-Maher-Saad/MedicalChatbot",
      githubLink: "https://github.com/Martino-Maher-Saad/MedicalChatbot",
    ),
  ];
}
