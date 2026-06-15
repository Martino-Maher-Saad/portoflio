import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../data/portfolio_data.dart';
import '../../../../core/services/supabase_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import 'upload_button.dart';

class PersonalInfoTab extends StatefulWidget {
  const PersonalInfoTab({super.key});

  @override
  State<PersonalInfoTab> createState() => _PersonalInfoTabState();
}

class _PersonalInfoTabState extends State<PersonalInfoTab> {
  final _infoFormKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _shortNameCtrl = TextEditingController();
  final _logoCtrl = TextEditingController();
  final _titlesCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  final _githubCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _cvUrlCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPersonalInfo();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _shortNameCtrl.dispose();
    _logoCtrl.dispose();
    _titlesCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _aboutCtrl.dispose();
    _githubCtrl.dispose();
    _linkedinCtrl.dispose();
    _cvUrlCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPersonalInfo() async {
    if (!SupabaseHelper.instance.isSupabaseAvailable) return;
    try {
      final info = await SupabaseHelper.instance.getPersonalInfo();
      _nameCtrl.text = info.name;
      _shortNameCtrl.text = info.shortName;
      _logoCtrl.text = info.logoText;
      _titlesCtrl.text = info.titles.join(', ');
      _emailCtrl.text = info.email;
      _phoneCtrl.text = info.phone;
      _locationCtrl.text = info.location;
      _aboutCtrl.text = info.aboutMe;
      _githubCtrl.text = info.github;
      _linkedinCtrl.text = info.linkedin;
      _cvUrlCtrl.text = info.cvUrl;
      _imageCtrl.text = info.imageUrl;
    } catch (e) {
      debugPrint("================ LOAD INFO ERROR ================");
      debugPrint("Error details: $e");
      if (e is PostgrestException) {
        debugPrint("Code: ${e.code}");
        debugPrint("Message: ${e.message}");
        debugPrint("Details: ${e.details}");
        debugPrint("Hint: ${e.hint}");
      }
      debugPrint("=================================================");
      _showSnackBar("Failed to load info: ${e is PostgrestException ? e.message : e.toString()}", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveInfo() async {
    if (!_infoFormKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final info = PersonalInfo(
        name: _nameCtrl.text,
        shortName: _shortNameCtrl.text,
        logoText: _logoCtrl.text,
        titles: _titlesCtrl.text.split(',').map((e) => e.trim()).toList(),
        email: _emailCtrl.text,
        phone: _phoneCtrl.text,
        location: _locationCtrl.text,
        aboutMe: _aboutCtrl.text,
        github: _githubCtrl.text,
        linkedin: _linkedinCtrl.text,
        cvUrl: _cvUrlCtrl.text,
        imageUrl: _imageCtrl.text,
      );
      await SupabaseHelper.instance.savePersonalInfo(info);
      _showSnackBar("Personal Info updated successfully!");
    } catch (e) {
      debugPrint("================ SAVE INFO ERROR ================");
      debugPrint("Error details: $e");
      if (e is PostgrestException) {
        debugPrint("Code: ${e.code}");
        debugPrint("Message: ${e.message}");
        debugPrint("Details: ${e.details}");
        debugPrint("Hint: ${e.hint}");
      }
      debugPrint("=================================================");
      _showSnackBar("Save failed: ${e is PostgrestException ? e.message : e.toString()}", isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
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
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffix,
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
      child: Form(
        key: _infoFormKey,
        child: Column(
          children: [
            _buildField(controller: _nameCtrl, label: "Name", validator: (v) => v!.isEmpty ? "Required" : null),
            _buildField(controller: _shortNameCtrl, label: "Short Display Name", validator: (v) => v!.isEmpty ? "Required" : null),
            _buildField(controller: _logoCtrl, label: "Logo Monogram (e.g. MMS.)", validator: (v) => v!.isEmpty ? "Required" : null),
            _buildField(controller: _titlesCtrl, label: "Titles (Comma separated values: e.g. Software Engineer, Flutter Developer)"),
            _buildField(controller: _emailCtrl, label: "Email"),
            _buildField(controller: _phoneCtrl, label: "Phone Number"),
            _buildField(controller: _locationCtrl, label: "Location"),
            
            // Image input + upload button
            Row(
              children: [
                Expanded(child: _buildField(controller: _imageCtrl, label: "Profile Image URL")),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: UploadButton(
                    folder: 'profile',
                    label: 'Upload Pic',
                    allowedExtensions: const ['png', 'jpg', 'jpeg'],
                    onUploadComplete: (url) => setState(() => _imageCtrl.text = url),
                  ),
                ),
              ],
            ),

            // CV input + upload button
            Row(
              children: [
                Expanded(child: _buildField(controller: _cvUrlCtrl, label: "Downloadable CV URL")),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: UploadButton(
                    folder: 'cv',
                    label: 'Upload CV',
                    allowedExtensions: const ['pdf'],
                    onUploadComplete: (url) => setState(() => _cvUrlCtrl.text = url),
                  ),
                ),
              ],
            ),

            _buildField(controller: _aboutCtrl, label: "Full bio description", maxLines: 5),
            _buildField(controller: _githubCtrl, label: "GitHub Profile Link"),
            _buildField(controller: _linkedinCtrl, label: "LinkedIn Profile Link"),
            const SizedBox(height: 16),
            _isSaving 
                ? const CircularProgressIndicator()
                : CustomButton(text: "Save Personal Information", isFilled: true, onPressed: _saveInfo),
          ],
        ),
      ),
    );
  }
}
