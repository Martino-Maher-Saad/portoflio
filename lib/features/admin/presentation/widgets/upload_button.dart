import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/services/supabase_helper.dart';

class UploadButton extends StatefulWidget {
  final String folder;
  final String label;
  final List<String>? allowedExtensions;
  final Function(String url) onUploadComplete;

  const UploadButton({
    super.key,
    required this.folder,
    required this.label,
    this.allowedExtensions,
    required this.onUploadComplete,
  });

  @override
  State<UploadButton> createState() => _UploadButtonState();
}

class _UploadButtonState extends State<UploadButton> {
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    try {
      final result = await FilePicker.pickFiles(
        type: widget.allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: widget.allowedExtensions,
        withData: true, // Crucial for Flutter Web
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final fileBytes = file.bytes;
      if (fileBytes == null) {
        throw 'Failed to read file bytes. Make sure withData is true.';
      }

      setState(() => _isUploading = true);

      // Sanitize filename
      final String safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9\._-]'), '_');
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_$safeName';
      
      final String? publicUrl = await SupabaseHelper.instance.uploadFile(
        folder: widget.folder,
        fileName: fileName,
        fileBytes: fileBytes,
      );

      if (publicUrl != null) {
        widget.onUploadComplete(publicUrl);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File uploaded successfully!'), backgroundColor: Colors.green),
          );
        }
      } else {
        throw 'Upload returned null URL';
      }
    } catch (e) {
      if (mounted) {
        String errMsg = e.toString();
        if (errMsg.toLowerCase().contains('bucket') || 
            errMsg.toLowerCase().contains('not found') || 
            errMsg.contains('404')) {
          errMsg = "Storage bucket 'portfolio_assets' was not found.\n"
              "Please open your Supabase Console -> Storage, and create a PUBLIC bucket named 'portfolio_assets' to enable uploads.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $errMsg'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUploading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: _pickAndUpload,
      icon: const Icon(Icons.cloud_upload_outlined, size: 16),
      label: Text(widget.label),
    );
  }
}
