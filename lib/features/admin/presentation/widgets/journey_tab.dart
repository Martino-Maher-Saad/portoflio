import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_helper.dart';
import '../../../../core/widgets/custom_button.dart';

class JourneyTab extends StatefulWidget {
  const JourneyTab({super.key});

  @override
  State<JourneyTab> createState() => _JourneyTabState();
}

class _JourneyTabState extends State<JourneyTab> {
  final _expFormKey = GlobalKey<FormState>();
  final _expCompanyCtrl = TextEditingController();
  final _expRoleCtrl = TextEditingController();
  final _expLocationCtrl = TextEditingController();
  final _expDescCtrl = TextEditingController();
  final _expOrderCtrl = TextEditingController();

  List<Map<String, dynamic>> _expList = [];
  bool _isLoading = true;
  bool _isSaving = false;
  int? _editingExpId;

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isPresent = true;
  bool _isEducation = false;

  @override
  void initState() {
    super.initState();
    _loadExperiences();
  }

  @override
  void dispose() {
    _expCompanyCtrl.dispose();
    _expRoleCtrl.dispose();
    _expLocationCtrl.dispose();
    _expDescCtrl.dispose();
    _expOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExperiences() async {
    if (!SupabaseHelper.instance.isSupabaseAvailable) return;
    try {
      final List<dynamic> expData = await Supabase.instance.client
          .from('experiences')
          .select()
          .order('display_order', ascending: true);
      setState(() {
        _expList = List<Map<String, dynamic>>.from(expData);
      });
    } catch (e) {
      debugPrint("================ LOAD JOURNEY ERROR ================");
      debugPrint("Error details: $e");
      if (e is PostgrestException) {
        debugPrint("Code: ${e.code}");
        debugPrint("Message: ${e.message}");
        debugPrint("Details: ${e.details}");
        debugPrint("Hint: ${e.hint}");
      }
      debugPrint("====================================================");
      _showSnackBar("Failed to load experiences: ${e is PostgrestException ? e.message : e.toString()}", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveExp() async {
    if (!_expFormKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await SupabaseHelper.instance.saveExperience(
        id: _editingExpId,
        company: _expCompanyCtrl.text,
        role: _expRoleCtrl.text,
        startIso: _startDate.toUtc().toIso8601String(),
        endIso: _isPresent ? null : _endDate?.toUtc().toIso8601String(),
        location: _expLocationCtrl.text,
        description: _expDescCtrl.text,
        isEducation: _isEducation,
        order: int.tryParse(_expOrderCtrl.text) ?? 0,
      );

      _showSnackBar("Journey Item saved!");
      _resetForm();
      _loadExperiences();
    } catch (e) {
      debugPrint("================ SAVE JOURNEY ERROR ================");
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

  Future<void> _deleteExp(int id) async {
    try {
      await SupabaseHelper.instance.deleteExperience(id);
      _showSnackBar("Journey Item deleted!");
      _loadExperiences();
    } catch (e) {
      debugPrint("================ DELETE JOURNEY ERROR ================");
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
      _editingExpId = null;
      _expCompanyCtrl.clear();
      _expRoleCtrl.clear();
      _expLocationCtrl.clear();
      _expDescCtrl.clear();
      _expOrderCtrl.clear();
      _isPresent = true;
      _isEducation = false;
      _startDate = DateTime.now();
      _endDate = null;
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Timeline milestones list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _expList.length,
            itemBuilder: (context, index) {
              final item = _expList[index];
              return Card(
                child: ListTile(
                  title: Text("${item['role']} at ${item['company']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item['is_education'] == true ? "Education Milestone" : "Professional Work"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () {
                          setState(() {
                            _editingExpId = item['id'];
                            _expCompanyCtrl.text = item['company'] ?? '';
                            _expRoleCtrl.text = item['role'] ?? '';
                            _expLocationCtrl.text = item['location'] ?? '';
                            _expDescCtrl.text = item['description'] ?? '';
                            _expOrderCtrl.text = (item['display_order'] ?? 0).toString();
                            _isEducation = item['is_education'] ?? false;
                            _startDate = DateTime.parse(item['start_date']);
                            if (item['end_date'] != null) {
                              _endDate = DateTime.parse(item['end_date']);
                              _isPresent = false;
                            } else {
                              _isPresent = true;
                              _endDate = null;
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteExp(item['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(height: 40),

          // Journey Item editor form
          Form(
            key: _expFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _editingExpId != null ? "Edit Journey Item" : "Add Journey Item",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _expCompanyCtrl,
                  label: "Company / Institution Name",
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                _buildField(
                  controller: _expRoleCtrl,
                  label: "Role / Degree Title",
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                _buildField(
                  controller: _expLocationCtrl,
                  label: "Location (e.g. Cairo, Egypt)",
                ),
                _buildField(
                  controller: _expDescCtrl,
                  label: "Description Paragraph",
                  maxLines: 4,
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                _buildField(
                  controller: _expOrderCtrl,
                  label: "Display Order",
                ),

                // Education Checkbox
                CheckboxListTile(
                  title: const Text("Is this an Education Milestone?"),
                  value: _isEducation,
                  onChanged: (val) => setState(() => _isEducation = val ?? false),
                ),

                // Start / End dates Picker Row
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Duration Timeline", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.calendar_month),
                              label: Text("Start: ${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}"),
                              onPressed: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (d != null) setState(() => _startDate = d);
                              },
                            ),
                            const Spacer(),
                            Checkbox(
                              value: _isPresent,
                              onChanged: (val) => setState(() {
                                _isPresent = val ?? true;
                                if (_isPresent) _endDate = null;
                              }),
                            ),
                            const Text("Present"),
                            const SizedBox(width: 8),
                            if (!_isPresent)
                              TextButton.icon(
                                icon: const Icon(Icons.calendar_month),
                                label: Text("End: ${_endDate != null ? "${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}" : "Select"}"),
                                onPressed: () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: _endDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (d != null) setState(() => _endDate = d);
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                _isSaving
                    ? const CircularProgressIndicator()
                    : Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: "Save Journey Item",
                              isFilled: true,
                              onPressed: _saveExp,
                            ),
                          ),
                          if (_editingExpId != null) ...[
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
