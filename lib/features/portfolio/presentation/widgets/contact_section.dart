import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../data/portfolio_data.dart';
import '../../../../utils/responsive_layout.dart';

class ContactSection extends StatefulWidget {
  final PersonalInfo personalInfo;

  const ContactSection({super.key, required this.personalInfo});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String subject = _subjectController.text.isNotEmpty
          ? _subjectController.text
          : "Portfolio Contact - ${_nameController.text}";
      final String phoneStr = _phoneController.text.isNotEmpty
          ? "\nPhone: ${_phoneController.text}"
          : "";
      final String body =
          "Hi ${widget.personalInfo.shortName},\n\n${_messageController.text}\n\nBest regards,\n${_nameController.text}\nEmail: ${_emailController.text}$phoneStr";

      final String emailUri =
          "mailto:${widget.personalInfo.email}"
          "?subject=${Uri.encodeComponent(subject)}"
          "&body=${Uri.encodeComponent(body)}";

      final messenger = ScaffoldMessenger.of(context);
      try {
        final uri = Uri.parse(emailUri);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          messenger.showSnackBar(
            const SnackBar(
              content: Text(AppStrings.contactSuccess),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw 'Could not launch mail client';
        }
      } catch (e) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(AppStrings.contactError),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isMobile = context.isMobile;

    Widget buildTextField({
      required TextEditingController controller,
      required String hintText,
      required IconData icon,
      int maxLines = 1,
      String? Function(String?)? validator,
    }) {
      return TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: AppTextStyles.outfit(color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.outfit(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          prefixIcon: Icon(icon, color: primaryColor, size: 20),
          filled: true,
          fillColor: theme.cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
      );
    }

    return Container(
      color: theme.cardColor.withOpacity(0.15),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSizes.paddingL : AppSizes.paddingXXL,
        vertical: isMobile
            ? AppSizes.sectionSpacingMobile
            : AppSizes.sectionSpacingDesktop,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const SectionTitle(
                firstPart: AppStrings.contactHeaderMain,
                coloredPart: AppStrings.contactHeaderSub,
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.contactSubtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.outfit(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 48),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!isMobile) ...[
                      Row(
                        children: [
                          Expanded(
                            child: buildTextField(
                              controller: _nameController,
                              hintText: AppStrings.formNameHint,
                              icon: Icons.person_outline,
                              validator: (val) =>
                                  val == null || val.trim().isEmpty
                                  ? AppStrings.validateNameEmpty
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: buildTextField(
                              controller: _emailController,
                              hintText: AppStrings.formEmailHint,
                              icon: Icons.email_outlined,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return AppStrings.validateEmailEmpty;
                                }
                                final emailRegex = RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                );
                                if (!emailRegex.hasMatch(val)) {
                                  return AppStrings.validateEmailInvalid;
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: buildTextField(
                              controller: _phoneController,
                              hintText: AppStrings.formPhoneHint,
                              icon: Icons.phone_outlined,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: buildTextField(
                              controller: _subjectController,
                              hintText: AppStrings.formSubjectHint,
                              icon: Icons.subject_outlined,
                              validator: (val) =>
                                  val == null || val.trim().isEmpty
                                  ? AppStrings.validateSubjectEmpty
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      buildTextField(
                        controller: _nameController,
                        hintText: AppStrings.formNameHint,
                        icon: Icons.person_outline,
                        validator: (val) => val == null || val.trim().isEmpty
                            ? AppStrings.validateNameEmpty
                            : null,
                      ),
                      const SizedBox(height: 16),
                      buildTextField(
                        controller: _emailController,
                        hintText: AppStrings.formEmailHint,
                        icon: Icons.email_outlined,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return AppStrings.validateEmailEmpty;
                          }
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(val)) {
                            return AppStrings.validateEmailInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      buildTextField(
                        controller: _phoneController,
                        hintText: AppStrings.formPhoneHint,
                        icon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: 16),
                      buildTextField(
                        controller: _subjectController,
                        hintText: AppStrings.formSubjectHint,
                        icon: Icons.subject_outlined,
                        validator: (val) => val == null || val.trim().isEmpty
                            ? AppStrings.validateSubjectEmpty
                            : null,
                      ),
                    ],
                    const SizedBox(height: 20),
                    buildTextField(
                      controller: _messageController,
                      hintText: AppStrings.formMessageHint,
                      icon: Icons.message_outlined,
                      maxLines: 6,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? AppStrings.validateMessageEmpty
                          : null,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: AppStrings.sendMessage,
                      isFilled: true,
                      onPressed: _submitForm,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
