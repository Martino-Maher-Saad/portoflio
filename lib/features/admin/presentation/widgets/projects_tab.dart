import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import 'upload_button.dart';

class ProjectsTab extends StatefulWidget {
  const ProjectsTab({super.key});

  @override
  State<ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<ProjectsTab> {
  final _projFormKey = GlobalKey<FormState>();
  final _projNameCtrl = TextEditingController();
  final _projSubtitleCtrl = TextEditingController();
  final _projDescCtrl = TextEditingController();
  final _projFeaturesCtrl = TextEditingController();
  final _projTechCtrl = TextEditingController();
  final _projOrderCtrl = TextEditingController();

  final List<Map<String, dynamic>> _tempProjLinks = [];
  final _linkLabelCtrl = TextEditingController();
  final _linkUrlCtrl = TextEditingController();
  String _linkType = 'github';

  final List<String> _screenshots = [];

  List<Map<String, dynamic>> _projList = [];
  bool _isLoading = true;
  bool _isSaving = false;
  int? _editingProjId;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  @override
  void dispose() {
    _projNameCtrl.dispose();
    _projSubtitleCtrl.dispose();
    _projDescCtrl.dispose();
    _projFeaturesCtrl.dispose();
    _projTechCtrl.dispose();
    _projOrderCtrl.dispose();
    _linkLabelCtrl.dispose();
    _linkUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    if (!SupabaseHelper.instance.isSupabaseAvailable) return;
    try {
      final List<dynamic> projData = await Supabase.instance.client
          .from('projects')
          .select()
          .order('display_order', ascending: true);
      setState(() {
        _projList = List<Map<String, dynamic>>.from(projData);
      });
    } catch (e) {
      debugPrint("================ LOAD PROJECTS ERROR ================");
      debugPrint("Error details: $e");
      if (e is PostgrestException) {
        debugPrint("Code: ${e.code}");
        debugPrint("Message: ${e.message}");
        debugPrint("Details: ${e.details}");
        debugPrint("Hint: ${e.hint}");
      }
      debugPrint("=====================================================");
      _showSnackBar("Failed to load projects: ${e is PostgrestException ? e.message : e.toString()}", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProj() async {
    if (!_projFormKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await SupabaseHelper.instance.saveProject(
        id: _editingProjId,
        name: _projNameCtrl.text,
        subtitle: _projSubtitleCtrl.text,
        description: _projDescCtrl.text,
        features: _projFeaturesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        techStack: _projTechCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        links: _tempProjLinks,
        screenshots: _screenshots,
        order: int.tryParse(_projOrderCtrl.text) ?? 0,
      );

      _showSnackBar("Project saved!");
      _resetForm();
      _loadProjects();
    } catch (e) {
      debugPrint("================ SAVE PROJECT ERROR ================");
      debugPrint("Error details: $e");
      if (e is PostgrestException) {
        debugPrint("Code: ${e.code}");
        debugPrint("Message: ${e.message}");
        debugPrint("Details: ${e.details}");
        debugPrint("Hint: ${e.hint}");
      }
      debugPrint("====================================================");
      _showSnackBar("Save failed: ${e is PostgrestException ? e.message : e.toString()}", isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteProj(int id) async {
    try {
      await SupabaseHelper.instance.deleteProject(id);
      _showSnackBar("Project deleted!");
      _loadProjects();
    } catch (e) {
      debugPrint("================ DELETE PROJECT ERROR ================");
      debugPrint("Error details: $e");
      if (e is PostgrestException) {
        debugPrint("Code: ${e.code}");
        debugPrint("Message: ${e.message}");
        debugPrint("Details: ${e.details}");
        debugPrint("Hint: ${e.hint}");
      }
      debugPrint("======================================================");
      _showSnackBar("Delete failed: ${e is PostgrestException ? e.message : e.toString()}", isError: true);
    }
  }

  void _resetForm() {
    setState(() {
      _editingProjId = null;
      _projNameCtrl.clear();
      _projSubtitleCtrl.clear();
      _projDescCtrl.clear();
      _projFeaturesCtrl.clear();
      _projTechCtrl.clear();
      _projOrderCtrl.clear();
      _tempProjLinks.clear();
      _screenshots.clear();
      _linkLabelCtrl.clear();
      _linkUrlCtrl.clear();
    });
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Project List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _projList.length,
            itemBuilder: (context, index) {
              final item = _projList[index];
              return Card(
                child: ListTile(
                  title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item['subtitle'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () {
                          setState(() {
                            _editingProjId = item['id'];
                            _projNameCtrl.text = item['name'] ?? '';
                            _projSubtitleCtrl.text = item['subtitle'] ?? '';
                            _projDescCtrl.text = item['description'] ?? '';
                            _projFeaturesCtrl.text = (item['features'] as List? ?? []).join(', ');
                            _projTechCtrl.text = (item['tech_stack'] as List? ?? []).join(', ');
                            _projOrderCtrl.text = (item['display_order'] ?? 0).toString();
                            
                            _tempProjLinks.clear();
                            final links = item['links'] as List? ?? [];
                            for (var l in links) {
                              if (l is Map) {
                                _tempProjLinks.add({
                                  'label': l['label']?.toString() ?? '',
                                  'url': l['url']?.toString() ?? '',
                                  'type': l['type']?.toString() ?? 'link',
                                });
                              }
                            }

                            _screenshots.clear();
                            final list = item['screenshots'] as List? ?? [];
                            _screenshots.addAll(list.map((e) => e.toString()));
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteProj(item['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(height: 40),

          // Project editor form
          Form(
            key: _projFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _editingProjId != null ? "Edit Project" : "Add Project",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                _buildField(controller: _projNameCtrl, label: "Project Name", validator: (v) => v!.isEmpty ? "Required" : null),
                _buildField(controller: _projSubtitleCtrl, label: "Subtitle (e.g. E-Commerce Solutions)"),
                _buildField(controller: _projDescCtrl, label: "Short Summary Description", maxLines: 3, validator: (v) => v!.isEmpty ? "Required" : null),
                _buildField(controller: _projFeaturesCtrl, label: "Features List (Comma separated values)", maxLines: 3),
                _buildField(controller: _projTechCtrl, label: "Tech Stack (Comma separated values)"),
                _buildField(controller: _projOrderCtrl, label: "Display Order"),

                // Project Screenshots Manager
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Screenshots", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    UploadButton(
                      folder: 'projects',
                      label: 'Upload Pic',
                      allowedExtensions: const ['png', 'jpg', 'jpeg'],
                      onUploadComplete: (url) => setState(() => _screenshots.add(url)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_screenshots.isEmpty)
                  const Text("No screenshots uploaded yet.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))
                else
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _screenshots.map((url) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 100,
                            height: 70,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                              image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: -8,
                            right: -8,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: IconButton(
                                iconSize: 10,
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () => setState(() => _screenshots.remove(url)),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),

                // Labeled links builder
                const Divider(height: 32),
                const Text("Add Labeled Redirect Links", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),

                // Current project links
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _tempProjLinks.length,
                  itemBuilder: (context, i) {
                    final link = _tempProjLinks[i];
                    return Card(
                      color: theme.scaffoldBackgroundColor,
                      child: ListTile(
                        title: Text(link['label'] ?? ''),
                        subtitle: Text(link['url'] ?? ''),
                        leading: const Icon(Icons.link),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () {
                                setState(() {
                                  _linkLabelCtrl.text = link['label'] ?? '';
                                  _linkUrlCtrl.text = link['url'] ?? '';
                                  _linkType = link['type'] ?? 'link';
                                  _tempProjLinks.removeAt(i);
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.redAccent),
                              onPressed: () => setState(() => _tempProjLinks.removeAt(i)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Links Input Section
                Row(
                  children: [
                    Expanded(child: _buildField(controller: _linkLabelCtrl, label: "Label (e.g. GitHub)")),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField(controller: _linkUrlCtrl, label: "URL")),
                  ],
                ),
                Row(
                  children: [
                    const Text("Link Type: "),
                    DropdownButton<String>(
                      value: _linkType,
                      onChanged: (val) => setState(() => _linkType = val ?? 'link'),
                      items: ['github', 'live', 'figma', 'video', 'link']
                          .map((type) => DropdownMenuItem(value: type, child: Text(type.toUpperCase())))
                          .toList(),
                    ),
                    const SizedBox(width: 12),
                    UploadButton(
                      folder: 'media',
                      label: 'Upload Video/File',
                      onUploadComplete: (url) => setState(() => _linkUrlCtrl.text = url),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      child: const Text("Add Link"),
                      onPressed: () {
                        if (_linkLabelCtrl.text.isEmpty || _linkUrlCtrl.text.isEmpty) return;
                        setState(() {
                          _tempProjLinks.add({
                            'label': _linkLabelCtrl.text,
                            'url': _linkUrlCtrl.text,
                            'type': _linkType,
                          });
                          _linkLabelCtrl.clear();
                          _linkUrlCtrl.clear();
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _isSaving
                    ? const CircularProgressIndicator()
                    : Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: "Save Project",
                              isFilled: true,
                              onPressed: _saveProj,
                            ),
                          ),
                          if (_editingProjId != null) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextButton(
                                onPressed: _resetForm,
                                child: const Text("Cancel Edit"),
                              ),
                            ),
                          ],
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
