import 'dart:convert';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/responsive.dart';
import '../../services/profile_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/base64_utils.dart';
import '../../main.dart'; // To access themeNotifier

class ProfileSection extends StatefulWidget {
  final AppUser user;
  final VoidCallback onLogout;
  final Function(String) onToast;
  final VoidCallback? onProfileUpdate;

  const ProfileSection({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onToast,
    this.onProfileUpdate,
  });

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  bool _notificationsOn = true;
  Map<String, dynamic>? _userData;
  bool _isLoadingData = false;
  String _imageCacheBuster = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void didUpdateWidget(ProfileSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent (MainAppScreen) resolves the ID from 0 to a real ID,
    // we must re-fetch the profile data.
    if (oldWidget.user.id != widget.user.id) {
      _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    if (!mounted) return;
    setState(() => _isLoadingData = true);

    // ── Fetch profile independently so a project error never wipes out the name ──
    try {
      final profile = await ProfileService.getMyProfile(
        role: widget.user.role,
        id: widget.user.id,
        email: widget.user.info.email,
      );
      debugPrint("PROFILE RAW DATA: $profile");
      if (mounted && profile != null) {
        setState(() {
          _userData = profile;
          _imageCacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
        });
      }
    } catch (e) {
      debugPrint("PROFILE FETCH ERROR: $e");
    }

    if (mounted) setState(() => _isLoadingData = false);
  }

  // Date formatting is handled by ProfileService.formatDate()

  void _openEditProfile(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          _EditProfileModal(user: widget.user, initialUserData: _userData),
    );

    if (result == true) {
      widget.onToast("Profile updated!");
      _fetchUserData(); // Refresh local data after update
      widget.onProfileUpdate?.call(); // Notify parent to refresh
    }
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
      imageQuality: 80, // Better quality supported natively
      maxWidth: 1024,
    );

    if (image != null) {
      widget.onToast("Uploading profile picture...");

      // Upload using the native multipart file mechanism instead of Base64 strings
      // preventing Hibernate JPA 'Data Too Long' transaction crashes.
      final success = await ProfileService.updateMyProfileImage(image.path);

      if (success) {
        widget.onToast("Profile picture updated!");
        // Force an instant refresh of the image cache by updating the buster
        if (mounted) {
          setState(() {
            _imageCacheBuster = DateTime.now().millisecondsSinceEpoch
                .toString();
          });
        }
        // Note: Re-fetch the profile to ensure the new image URL syncs
        _fetchUserData();
        widget.onProfileUpdate?.call(); // Notify parent to refresh
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
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onLogout();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
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

    // ── Name resolution: Sync widget.user.info with _userData ──
    final String apiName = ProfileService.extractFullName(_userData);
    final String email =
        _userData?['email']?.toString() ?? widget.user.info.email;

    // Ultimate fallback: If the database and token both entirely lacked a name,
    // gracefully derive a display name from the email (e.g. sharmaji@gmail.com -> Sharmaji)
    String fullName = apiName.isNotEmpty ? apiName : widget.user.info.name;
    if (fullName.trim().isEmpty && email.contains('@')) {
      final prefix = email.split('@')[0];
      if (prefix.isNotEmpty) {
        fullName = prefix[0].toUpperCase() + prefix.substring(1).toLowerCase();
      }
    } else if (fullName.trim().isEmpty) {
      fullName = 'Unknown User';
    }

    final dynamic rawId = _userData?['id'] ?? widget.user.id;
    final String displayId = widget.user.role == UserRole.client
        ? 'CL-${rawId.toString().padLeft(3, '0')}'
        : ProfileService.formatEmployeeId(rawId);

    final String? rawJoinDate =
        _userData?['join_date']?.toString() ??
        _userData?['joinDate']?.toString() ??
        (widget.user.info.joinDate.isNotEmpty
            ? widget.user.info.joinDate
            : null);
    final String joinDateString = ProfileService.formatDate(rawJoinDate);

    final String? adhar =
        _userData?['adhar_number']?.toString() ??
        _userData?['adharNumber']?.toString();
    final String? pan =
        _userData?['pan_number']?.toString() ??
        _userData?['panNumber']?.toString();
    final String phone =
        _userData?['phone']?.toString() ??
        _userData?['mobile']?.toString() ??
        widget.user.info.phone;

    if (_isLoadingData && _userData == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

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
                borderRadius: BorderRadius.circular(16.w),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.15),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  // Gold banner
                  Container(
                    height: 90.h,
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
                                onTap: widget.user.role == UserRole.client
                                    ? null
                                    : _pickImage,
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
                                    if (widget.user.role != UserRole.client)
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
                                // If API name is blank and fallback failed, 'fullName' holds our derived name.
                                fullName.isNotEmpty
                                    ? fullName
                                    : (_isLoadingData
                                          ? 'Loading...'
                                          : 'Unknown User'),
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
                                children: [
                                  const GoldChip(
                                    text: 'Active',
                                    bg: AppColors.chipDoneBg,
                                    fg: AppColors.chipDoneFg,
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text(
                                      displayId,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    backgroundColor: const Color(0x26B8952A),
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
                          'val': email,
                        },
                        {
                          'icon': Icons.phone_rounded,
                          'label': 'Phone',
                          'val': phone,
                        },
                        {
                          'icon': Icons.home_work_rounded,
                          'label': widget.user.role == UserRole.client
                              ? 'Address'
                              : 'Office',
                          'val':
                              _userData?['address']?.toString() ??
                              'YW Architects HQ, Pune',
                        },
                        if (widget.user.role != UserRole.client)
                          {
                            'icon': Icons.calendar_today_rounded,
                            'label': 'Date of Joining',
                            'val': joinDateString,
                          },
                        if (widget.user.role == UserRole.client)
                          {
                            'icon': Icons.description_rounded,
                            'label': 'GST Certificate',
                            'val':
                                _userData?['gstcertificate']?.toString() ??
                                widget.user.info.gstCertificate,
                          },
                        if (adhar != null &&
                            adhar.isNotEmpty &&
                            adhar != "0" &&
                            widget.user.role != UserRole.client)
                          {
                            'icon': Icons.badge_rounded,
                            'label': 'Aadhaar Card',
                            'val': adhar,
                          },
                        if ((pan != null && pan.isNotEmpty) ||
                            widget.user.role == UserRole.client)
                          {
                            'icon': Icons.credit_card_rounded,
                            'label': widget.user.role == UserRole.client
                                ? 'PAN Number'
                                : 'PAN Card',
                            'val': pan ?? widget.user.info.pan,
                          },
                      ]
                      .where(
                        (e) =>
                            e['val'].toString().isNotEmpty && e['val'] != '—',
                      )
                      .map(
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
                      )
                      .toList()),
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
                  color: AppColors.outlineVariant.withValues(alpha: 0.15),
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
                                      themeNotifier.value = v
                                          ? ThemeMode.dark
                                          : ThemeMode.light;
                                    }
                                  }),
                                  activeThumbColor: AppColors.primary,
                                )
                              : (s['label'] == 'Language'
                                    ? null
                                    : const Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppColors.onSurfaceVariant,
                                      )),
                          onTap: (isToggle || s['label'] == 'Language')
                              ? null
                              : () {
                                  if (s['label'] == 'Change Password')
                                    _openChangePassword();
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
                    Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
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
    final imageUrl =
        _userData?['profileImage']?.toString() ?? widget.user.info.profileImage;

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
        // Handle as URL with cache-busting query parameter to force instant refresh
        final bustedUrl = imageUrl.contains('?')
            ? '$imageUrl&v=$_imageCacheBuster'
            : '$imageUrl?v=$_imageCacheBuster';

        return Image.network(
          bustedUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitials(),
        );
      }
    }

    return _buildInitials();
  }

  Widget _buildInitials() {
    final String apiName = ProfileService.extractFullName(_userData);
    String initials = '';

    if (apiName.isNotEmpty) {
      final parts = apiName.split(' ');
      if (parts.length > 1) {
        initials =
            (parts[0].isNotEmpty ? parts[0][0] : '') +
            (parts[parts.length - 1].isNotEmpty
                ? parts[parts.length - 1][0]
                : '');
      } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
        initials = parts[0][0];
      }
    } else {
      initials = widget.user.info.initials;
    }

    return Container(
      decoration: BoxDecoration(gradient: goldGradient),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class _EditProfileModal extends StatefulWidget {
  final AppUser user;
  final Map<String, dynamic>? initialUserData;
  const _EditProfileModal({required this.user, this.initialUserData});

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
    final d = widget.initialUserData;
    _firstNameController = TextEditingController(
      text:
          d?['first_name']?.toString() ??
          d?['firstName']?.toString() ??
          widget.user.info.firstName,
    );
    _lastNameController = TextEditingController(
      text:
          d?['last_name']?.toString() ??
          d?['lastName']?.toString() ??
          widget.user.info.lastName,
    );
    _phoneController = TextEditingController(
      text: d?['phone']?.toString() ?? "9876543210",
    );
    _birthDateController = TextEditingController(
      text:
          d?['birth_date']?.toString() ??
          d?['birthDate']?.toString() ??
          "1995-01-01",
    );

    if (d != null) {
      final gender = d['gender']?.toString().toUpperCase();
      if (gender != null) _selectedGender = gender;

      final blood = (d['blood_group'] ?? d['bloodGroup'])
          ?.toString()
          .toUpperCase();
      if (blood != null) _selectedBlood = blood;
    }
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
        _birthDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final payload = {
        "id": widget.user.id,
        "first_name": _firstNameController.text.trim(),
        "last_name": _lastNameController.text.trim(),
        "firstName": _firstNameController.text
            .trim(), // Dual mapping for compatibility
        "lastName": _lastNameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "email": widget.user.info.email,
        "gender": _selectedGender,
        "blood_group": _selectedBlood,
        "bloodGroup": _selectedBlood,
        "birth_date": _birthDateController.text.trim(),
        "birthDate": _birthDateController.text.trim(),
      };

      final success = await ProfileService.updateMyProfile(payload);
      if (success) {
        if (mounted) Navigator.pop(context, true);
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update profile")),
          );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Edit Profile",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildField("First Name", _firstNameController),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField("Last Name", _lastNameController),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildField(
                "Phone Number",
                _phoneController,
                keyboard: TextInputType.phone,
                maxLength: 10,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required";
                  final digitsOnly = v.replaceAll(RegExp(r'\D'), '');
                  if (digitsOnly.length != 10)
                    return "Must be exactly 10 digits";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (widget.user.role != UserRole.client) ...[
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: _buildField(
                      "Birth Date",
                      _birthDateController,
                      icon: Icons.calendar_today_rounded,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        "Gender",
                        _selectedGender,
                        ["MALE", "FEMALE", "OTHER"],
                        (v) => setState(() => _selectedGender = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        "Blood Group",
                        _selectedBlood,
                        ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"],
                        (v) => setState(() => _selectedBlood = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ] else ...[
                const SizedBox(height: 8),
              ],
              _isSaving
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : GoldGradientButton(
                      text: "Save Changes",
                      verticalPadding: 16,
                      onTap: _save,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboard,
    IconData? icon,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          maxLength: maxLength,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: icon != null
                ? Icon(icon, size: 16, color: AppColors.onSurfaceVariant)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator:
              validator ?? ((v) => v == null || v.isEmpty ? "Required" : null),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
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

  bool _oldVisible = false;
  bool _newVisible = false;
  bool _confirmVisible = false;

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
      final success = await ProfileService.updateMyPassword(
        _oldController.text,
        _newController.text,
      );
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
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Change Password",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          _buildField(
            "Current Password",
            _oldController,
            obscure: true,
            isVisible: _oldVisible,
            onVisibilityToggle: () =>
                setState(() => _oldVisible = !_oldVisible),
          ),
          const SizedBox(height: 16),
          _buildField(
            "New Password",
            _newController,
            obscure: true,
            isVisible: _newVisible,
            onVisibilityToggle: () =>
                setState(() => _newVisible = !_newVisible),
          ),
          const SizedBox(height: 16),
          _buildField(
            "Confirm New Password",
            _confirmController,
            obscure: true,
            isVisible: _confirmVisible,
            onVisibilityToggle: () =>
                setState(() => _confirmVisible = !_confirmVisible),
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : GoldGradientButton(text: "Update Password", onTap: _submit),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure && !isVisible,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: obscure
                ? IconButton(
                    icon: Icon(
                      isVisible
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: onVisibilityToggle,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
