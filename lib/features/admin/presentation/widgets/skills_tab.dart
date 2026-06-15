import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_helper.dart';
import '../../../../core/widgets/custom_button.dart';

class SkillsTab extends StatefulWidget {
  const SkillsTab({super.key});

  @override
  State<SkillsTab> createState() => _SkillsTabState();
}

class _SkillsTabState extends State<SkillsTab> {
  final _skillFormKey = GlobalKey<FormState>();
  final _skillCategoryCtrl = TextEditingController();
  final _skillItemsCtrl = TextEditingController();
  final _skillOrderCtrl = TextEditingController();

  List<Map<String, dynamic>> _skillsList = [];
  bool _isLoading = true;
  bool _isSaving = false;
  int? _editingSkillId;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  @override
  void dispose() {
    _skillCategoryCtrl.dispose();
    _skillItemsCtrl.dispose();
    _skillOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSkills() async {
    if (!SupabaseHelper.instance.isSupabaseAvailable) return;
    try {
      final List<dynamic> skillsData = await Supabase.instance.client
          .from('skills')
          .select()
          .order('display_order', ascending: true);
      setState(() {
        _skillsList = List<Map<String, dynamic>>.from(skillsData);
      });
    } catch (e) {
      debugPrint("================ LOAD SKILLS ERROR ================");
      debugPrint("Error details: $e");
      if (e is PostgrestException) {
        debugPrint("Code: ${e.code}");
        debugPrint("Message: ${e.message}");
        debugPrint("Details: ${e.details}");
        debugPrint("Hint: ${e.hint}");
      }
      debugPrint("==================================================");
      _showSnackBar("Failed to load skills: ${e is PostgrestException ? e.message : e.toString()}", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSkillCategory() async {
    if (!_skillFormKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final String cat = _skillCategoryCtrl.text;
      final List<String> list = _skillItemsCtrl.text.split(',').map((e) => e.trim()).toList();
      final int order = int.tryParse(_skillOrderCtrl.text) ?? 0;

      await SupabaseHelper.instance.saveSkill(
        _editingSkillId,
        cat,
        list,
        order,
      );

      _showSnackBar("Skill Category saved!");
      _resetForm();
      _loadSkills();
    } catch (e) {
      debugPrint("================ SAVE SKILL ERROR ================");
      debugPrint("Error details: $e");
      if (e is PostgrestException) {
        debugPrint("Code: ${e.code}");
        debugPrint("Message: ${e.message}");
        debugPrint("Details: ${e.details}");
        debugPrint("Hint: ${e.hint}");
      }
      debugPrint("==================================================");
      _showSnackBar("Save failed: ${e is PostgrestException ? e.message : e.toString()}", isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteSkill(int id) async {
    try {
      await SupabaseHelper.instance.deleteSkill(id);
      _showSnackBar("Skill Category deleted!");
      _loadSkills();
    } catch (e) {
      debugPrint("================ DELETE SKILL ERROR ================");
      debugPrint("Error details: $e");
      if (e is PostgrestException) {
        debugPrint("Code: ${e.code}");
        debugPrint("Message: ${e.message}");
        debugPrint("Details: ${e.details}");
        debugPrint("Hint: ${e.hint}");
      }
      debugPrint("====================================================");
      _showSnackBar("Delete failed: ${e is PostgrestException ? e.message : e.toString()}", isError: true);
    }
  }

  void _resetForm() {
    setState(() {
      _editingSkillId = null;
      _skillCategoryCtrl.clear();
      _skillItemsCtrl.clear();
      _skillOrderCtrl.clear();
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
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Skills Category List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _skillsList.length,
            itemBuilder: (context, index) {
              final item = _skillsList[index];
              final skillsText = (item['skills_list'] as List).join(', ');
              return Card(
                child: ListTile(
                  title: Text(item['category_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(skillsText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () {
                          setState(() {
                            _editingSkillId = item['id'];
                            _skillCategoryCtrl.text = item['category_name'] ?? '';
                            _skillItemsCtrl.text = skillsText;
                            _skillOrderCtrl.text = (item['display_order'] ?? 0).toString();
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteSkill(item['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(height: 40),

          // Skill form
          Form(
            key: _skillFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _editingSkillId != null ? "Edit Skill Category" : "Add New Skill Category",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _skillCategoryCtrl,
                  label: "Category Name (e.g. Mobile Development)",
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                _buildField(
                  controller: _skillItemsCtrl,
                  label: "Skills list (Comma separated values: e.g. Flutter, Dart)",
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                _buildField(
                  controller: _skillOrderCtrl,
                  label: "Display Order (e.g. 0, 1, 2)",
                ),
                const SizedBox(height: 16),
                _isSaving
                    ? const CircularProgressIndicator()
                    : Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: "Save Skill Category",
                              isFilled: true,
                              onPressed: _saveSkillCategory,
                            ),
                          ),
                          if (_editingSkillId != null) ...[
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
