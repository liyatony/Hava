import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'dart:typed_data';

class FeedbackFormScreen extends StatefulWidget {
  final String feedbackType;
  const FeedbackFormScreen({super.key, required this.feedbackType});

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final List<XFile> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _errorMessage;
  
  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(pickedFiles);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking images: $e';
      });
    }
  }

  String _getContentType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg': case '.jpeg': return 'image/jpeg';
      case '.png': return 'image/png';
      case '.gif': return 'image/gif';
      case '.webp': return 'image/webp';
      case '.pdf': return 'application/pdf';
      case '.mp4': return 'video/mp4';
      case '.mov': return 'video/quicktime';
      case '.doc': return 'application/msword';
      case '.docx': return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.xls': return 'application/vnd.ms-excel';
      case '.xlsx': return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case '.txt': return 'text/plain';
      default: return 'application/octet-stream';
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;
      
      final feedbackData = {
        'subject': _subjectController.text,
        'city': _cityController.text,
        'description': _descriptionController.text,
        'email': _emailController.text.isEmpty ? null : _emailController.text,
        'created_at': DateTime.now().toIso8601String(),
        'status': 'pending',
      };

      final response = await supabase
          .from('feedback')
          .insert(feedbackData)
          .select()
          .single();
      
      final feedbackId = response['id'];
      final List<String> fileUrls = [];
      
      if (_selectedFiles.isNotEmpty) {
        for (final xFile in _selectedFiles) {
          final bytes = await xFile.readAsBytes();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(xFile.path)}';
          final contentType = _getContentType(xFile.path);
          
          // Fixed upload part - explicitly setting contentType in the correct format
          final uploadResponse = await supabase.storage
              .from('feedback_attachments')
              .uploadBinary(
                fileName,
                bytes,
                fileOptions: FileOptions(
                  cacheControl: '3600',
                  contentType: contentType,
                  upsert: true,
                ),
              );
              
          if (uploadResponse.isEmpty) {
            debugPrint('Upload successful for $fileName with content type: $contentType');
          } else {
            debugPrint('Upload failed: $uploadResponse');
          }
              
          final fileUrl = supabase.storage
              .from('feedback_attachments')
              .getPublicUrl(fileName);
          
          fileUrls.add(fileUrl);
          
          await supabase
              .from('feedback_attachments')
              .insert({
                'feedback_id': feedbackId,
                'file_path': 'feedback_attachments/$fileName',
                'file_name': fileName,
                'content_type': contentType, // Make sure this matches what's uploaded
              });
        }
      }
      
      if (fileUrls.isNotEmpty) {
        await supabase
            .from('feedback')
            .update({'attachments': fileUrls})
            .eq('id', feedbackId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      debugPrint('Error details: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error submitting feedback: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _subjectController.text = widget.feedbackType;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EDFF),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFEADDFF).withOpacity(0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3],
                ),
              ),
            ),
          ),
          _isUploading
              ? _buildLoadingIndicator()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        _buildBackButton(),
                        const SizedBox(height: 20),
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _buildFormContent(),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade800),
                            ),
                          ),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(18),
          child: const Icon(
            Icons.chevron_left,
            color: Color(0xFF1C1B1F),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Developers',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF381E72),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We appreciate your feedback to improve our app',
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF381E72).withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6750A4)),
          ),
          SizedBox(height: 24),
          Text(
            'Submitting your feedback...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF381E72),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField(
            label: 'Subject',
            controller: _subjectController,
            readOnly: true,
          ),
          const SizedBox(height: 24),
          _buildInputField(
            label: 'City',
            controller: _cityController,
            hintText: 'Enter the location where the problem occurred',
          ),
          const SizedBox(height: 24),
          _buildInputField(
            label: 'Describe the problem in detail',
            controller: _descriptionController,
            maxLines: 5,
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 24),
          _buildUploadSection(),
          const SizedBox(height: 24),
          _buildInputField(
            label: 'Email (optional)',
            controller: _emailController,
            hintText: 'To receive a response to your request',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 32),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF6750A4),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo or video that illustrates the issue',
          style: TextStyle(
            color: const Color(0xFF6750A4),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _pickImages,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE8DEF8),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 40,
                    color: const Color(0xFF6750A4).withOpacity(0.7),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to upload files',
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF6750A4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Up to 20 files, each up to 20 MB in size',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF6750A4).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_selectedFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildFilePreviewSection(),
        ],
      ],
    );
  }

  Widget _buildFilePreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected Files',
          style: TextStyle(
            color: Color(0xFF6750A4),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedFiles.map((xFile) {
            final isImage = ['.jpg', '.jpeg', '.png', '.gif', '.webp']
                .contains(path.extension(xFile.path).toLowerCase());
                
            return Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE8DEF8)),
                  ),
                  child: isImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FutureBuilder<Uint8List>(
                            future: xFile.readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done && 
                                  snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                );
                              }
                            },
                          ),
                        )
                      : Center(
                          child: Icon(
                            _getFileIcon(xFile.path),
                            size: 40,
                            color: const Color(0xFF6750A4),
                          ),
                        ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: InkWell(
                    onTap: () => setState(() => _selectedFiles.remove(xFile)),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.close, size: 16, color: Colors.black54),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      path.basename(xFile.path),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getFileIcon(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.pdf': return Icons.picture_as_pdf;
      case '.doc': case '.docx': return Icons.description;
      case '.xls': case '.xlsx': return Icons.table_chart;
      case '.mp4': case '.mov': return Icons.videocam;
      default: return Icons.insert_drive_file;
    }
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6750A4),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Submit Feedback',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}