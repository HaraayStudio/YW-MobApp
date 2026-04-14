import 'dart:convert';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../widgets/common_widgets.dart';
import '../../services/employee_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/base64_utils.dart';
import '../../main.dart'; // To access themeNotifier

class ProfileSection extends StatefulWidget {
  final AppUser user;
  final VoidCallback onLogout;
  final Function(String) onToast;

  const ProfileSection({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onToast,
  });

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  bool _notificationsOn = true;

  void _openEditProfile(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditProfileModal(user: widget.user),
    );

    if (result == true) {
      widget.onToast("Profile updated!");
    }
  }

  void _openLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _LanguageModal(),
    );
  }

  void _openChangePassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ChangePasswordModal(onToast: widget.onToast),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Reduce size for Base64 storage
      maxWidth: 512,
    );
    
    if (image != null) {
      widget.onToast("Uploading profile picture...");
      
      final base64String = await Base64Utils.toDataUrl(image);
      if (base64String == null) {
        widget.onToast("Failed to process image.");
        return;
      }

      // We send it via updateMyProfile because it's a JSON-based update
      final success = await EmployeeService.updateMyProfile({
        "id": widget.user.id,
        "email": widget.user.info.email,
        "profileImage": base64String,
      });

      if (success) {
        widget.onToast("Profile picture updated!");
        // Note: In a real app, you'd trigger a state refresh higher up
        // to update the global user object.
      } else {
        widget.onToast("Failed to upload image.");
      }
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onLogout();
            },
            child: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = [
      {
        'icon': Icons.notifications_rounded,
        'label': 'Notifications',
        'sub': 'Push & email alerts',
        'toggle': true,
        'key': 'notif',
      },
      {
        'icon': Icons.dark_mode_rounded,
        'label': 'Dark Mode',
        'sub': 'Appearance',
        'toggle': true,
        'key': 'dark',
      },
      {
        'icon': Icons.language_rounded,
        'label': 'Language',
        'sub': 'English (India)',
        'toggle': false,
        'key': '',
      },
      {
        'icon': Icons.security_rounded,
        'label': 'Change Password',
        'sub': 'Security settings',
        'toggle': false,
        'key': '',
      },
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Profile Hero
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withOpacity(0.15),
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: [
                // Gold banner
                Container(
                  height: 90,
                  decoration: BoxDecoration(gradient: goldGradient),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -28),
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                      color: AppColors.surfaceContainerLow,
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: _buildProfileImage(),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        size: 10,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: GestureDetector(
                              onTap: () => _openEditProfile(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.edit_rounded,
                                      size: 14,
                                      color: AppColors.onSurface,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Transform.translate(
                        offset: const Offset(0, -12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.user.info.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              widget.user.info.label,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: const [
                                GoldChip(
                                  text: 'Active',
                                  bg: AppColors.chipDoneBg,
                                  fg: AppColors.chipDoneFg,
                                ),
                                SizedBox(width: 8),
                                Chip(
                                  label: Text(
                                    'YW-2024-007',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  backgroundColor: Color(0x26B8952A),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick stats
          Row(
            children: [
              _stat('4', 'Projects'),
              const SizedBox(width: 10),
              _stat('38', 'Tasks'),
              const SizedBox(width: 10),
              _stat('8', 'Days Left'),
            ],
          ),
          const SizedBox(height: 16),

          // Account info
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Information',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                ...([
                  {
                    'icon': Icons.mail_rounded,
                    'label': 'Email',
                    'val': widget.user.info.email,
                  },
                  {
                    'icon': Icons.phone_rounded,
                    'label': 'Phone',
                    'val': '+91 98765 43210',
                  },
                  {
                    'icon': Icons.home_work_rounded,
                    'label': 'Office',
                    'val': 'YW Architects HQ, Pune',
                  },
                  {
                    'icon': Icons.badge_rounded,
                    'label': 'Employee ID',
                    'val': 'YW-2024-007',
                  },
                  {
                    'icon': Icons.calendar_today_rounded,
                    'label': 'Date of Joining',
                    'val': '15 March 2024',
                  },
                ]).map(
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            i['icon'] as IconData,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              i['label'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              i['val'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Settings
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withOpacity(0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                ...settings.asMap().entries.map((entry) {
                  final i = entry.key;
                  final s = entry.value;
                  final isToggle = s['toggle'] as bool;
                  return Column(
                    children: [
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            s['icon'] as IconData,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          s['label'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          s['sub'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        trailing: isToggle
                            ? Switch(
                                value: s['key'] == 'notif'
                                    ? _notificationsOn
                                    : (themeNotifier.value == ThemeMode.dark),
                                onChanged: (v) => setState(() {
                                  if (s['key'] == 'notif') {
                                    _notificationsOn = v;
                                  } else {
                                    themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                                  }
                                }),
                                activeThumbColor: AppColors.primary,
                              )
                            : const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.onSurfaceVariant,
                              ),
                        onTap: isToggle
                            ? null
                            : () {
                                if (s['label'] == 'Language') _openLanguagePicker();
                                if (s['label'] == 'Change Password') _openChangePassword();
                              },
                      ),
                      if (i < settings.length - 1)
                        const Divider(
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                          color: Color(0x1AD0C5B0),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _confirmLogout,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildProfileImage() {
    final imageUrl = widget.user.info.profileImage;
    
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (Base64Utils.isBase64(imageUrl)) {
        try {
          final base64String = imageUrl.split(',').last;
          return Image.memory(
            base64Decode(base64String),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildInitials(),
          );
        } catch (e) {
          return _buildInitials();
        }
      } else {
        // Handle as URL
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitials(),
        );
      }
    }
    
    return _buildInitials();
  }

  Widget _buildInitials() {
    return Container(
      decoration: BoxDecoration(gradient: goldGradient),
      child: Center(
        child: Text(
          widget.user.info.initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _stat(String val, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileModal extends StatefulWidget {
  final AppUser user;
  const _EditProfileModal({required this.user});

  @override
  State<_EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<_EditProfileModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _birthDateController;
  
  String _selectedGender = "MALE";
  String _selectedBlood = "B+";
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.info.firstName);
    _lastNameController = TextEditingController(text: widget.user.info.lastName);
    _phoneController = TextEditingController(text: "9876543210"); 
    _birthDateController = TextEditingController(text: "1995-01-01");
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 1, 1),
      firstDate: DateTime(1960),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final payload = {
        "firstName": _firstNameController.text.trim(),
        "lastName": _lastNameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "email": widget.user.info.email,
        "gender": _selectedGender,
        "bloodGroup": _selectedBlood,
        "birthDate": _birthDateController.text.trim(),
      };

      final success = await EmployeeService.updateMyProfile(payload);
      if (success) {
        if (mounted) Navigator.pop(context, true);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update profile")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text("Edit Profile", style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildField("First Name", _firstNameController)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField("Last Name", _lastNameController)),
                ],
              ),
              const SizedBox(height: 16),
              _buildField("Phone Number", _phoneController, keyboard: TextInputType.phone),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(child: _buildField("Birth Date", _birthDateController, icon: Icons.calendar_today_rounded)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDropdown("Gender", _selectedGender, ["MALE", "FEMALE", "OTHER"], (v) => setState(() => _selectedGender = v!))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDropdown("Blood Group", _selectedBlood, ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"], (v) => setState(() => _selectedBlood = v!))),
                ],
              ),
              const SizedBox(height: 24),
              _isSaving 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : GoldGradientButton(text: "Save Changes", verticalPadding: 16, onTap: _save),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {TextInputType? keyboard, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: icon != null ? Icon(icon, size: 16, color: AppColors.onSurfaceVariant) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _LanguageModal extends StatelessWidget {
  const _LanguageModal();

  @override
  Widget build(BuildContext context) {
    final languages = [
      {'name': 'English (India)', 'code': 'en_IN'},
      {'name': 'Hindi', 'code': 'hi_IN'},
      {'name': 'Marathi', 'code': 'mr_IN'},
    ];
    return Container(
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          const Text("Select Language", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ...languages.map((l) => ListTile(
            title: Text(l['name']!),
            trailing: l['code'] == 'en_IN' ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
            onTap: () => Navigator.pop(context),
          )),
        ],
      ),
    );
  }
}

class _ChangePasswordModal extends StatefulWidget {
  final Function(String) onToast;
  const _ChangePasswordModal({required this.onToast});

  @override
  State<_ChangePasswordModal> createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<_ChangePasswordModal> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_newController.text != _confirmController.text) {
      widget.onToast("Passwords don't match");
      return;
    }
    if (_newController.text.length < 6) {
      widget.onToast("Password must be at least 6 digits");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await EmployeeService.updateMyPassword(_oldController.text, _newController.text);
      if (success) {
        widget.onToast("Password changed successfully!");
        if (mounted) Navigator.pop(context);
      } else {
        widget.onToast("Failed to change password. Check old password.");
      }
    } catch (e) {
      widget.onToast("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          const Text("Change Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          _buildField("Current Password", _oldController, obscure: true),
          const SizedBox(height: 16),
          _buildField("New Password", _newController, obscure: true),
          const SizedBox(height: 16),
          _buildField("Confirm New Password", _confirmController, obscure: true),
          const SizedBox(height: 24),
          _isLoading 
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : GoldGradientButton(text: "Update Password", onTap: _submit),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
