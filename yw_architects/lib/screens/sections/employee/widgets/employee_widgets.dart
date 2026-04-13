import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yw_architects/theme/app_theme.dart';
import 'package:yw_architects/widgets/common_widgets.dart';
import 'package:yw_architects/models/app_models.dart';
import 'package:yw_architects/services/employee_service.dart';
import 'package:yw_architects/screens/sections/employee/models/employee_models.dart';

class EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;
  final VoidCallback onTap;
  final Function(String) onToast;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onTap,
    required this.onToast,
  });

  @override
  Widget build(BuildContext context) {
    final e = employee;
    return CardContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AvatarWidget(initials: e.initials, size: 48, fontSize: 15),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.onSurface), overflow: TextOverflow.ellipsis)),
                    GoldChip(
                        text: e.status, 
                        bg: e.status.toLowerCase() == 'active' ? AppColors.chipDoneBg : AppColors.chipHoldBg, 
                        fg: e.status.toLowerCase() == 'active' ? AppColors.chipDoneFg : AppColors.chipHoldFg),
                  ],
                ),
                const SizedBox(height: 2),
                Text(e.roleLabel, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.folder_open_rounded, size: 12, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('${e.projects} projects', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    const SizedBox(width: 12),
                    const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('Since ${e.since}', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.outlineVariant, size: 20),
        ],
      ),
    );
  }
}

class AddEmployeeModal extends StatefulWidget {
  final Function(String) onToast;
  final VoidCallback onSuccess;

  const AddEmployeeModal({super.key, required this.onToast, required this.onSuccess});

  @override
  State<AddEmployeeModal> createState() => _AddEmployeeModalState();
}

class _AddEmployeeModalState extends State<AddEmployeeModal> {
  final _formKey = GlobalKey<FormState>();
  final _fNameCtrl = TextEditingController();
  final _lNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  
  UserRole _selectedRole = UserRole.jrArchitect;
  bool _isLoading = false;
  bool _passVisible = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final payload = {
        'firstName': _fNameCtrl.text.trim(),
        'lastName': _lNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'role': roleToBackend(_selectedRole),
        'status': 'ACTIVE',
      };

      final success = await EmployeeService.createEmployee(payload);
      if (success) {
        widget.onToast("Employee added successfully!");
        widget.onSuccess();
        if (mounted) Navigator.pop(context);
      } else {
        widget.onToast("Failed to add employee.");
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
      padding: EdgeInsets.only(left: 24, right: 24, top: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              const _ModalHeader(title: 'Register New Employee'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _EmpFormField(label: 'FIRST NAME', controller: _fNameCtrl)),
                  const SizedBox(width: 16),
                  Expanded(child: _EmpFormField(label: 'LAST NAME', controller: _lNameCtrl)),
                ],
              ),
              const SizedBox(height: 16),
              _EmpFormField(label: 'EMAIL ADDRESS', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _EmpFormField(label: 'PHONE NUMBER', controller: _phoneCtrl, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _PasswordInputField(controller: _passCtrl, visible: _passVisible, onToggle: () => setState(() => _passVisible = !_passVisible)),
              const SizedBox(height: 16),
              _EmpDropdown<UserRole>(
                label: 'OFFICIAL ROLE',
                value: _selectedRole,
                items: roleMap.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value.name))).toList(),
                onChanged: (v) => setState(() => _selectedRole = v!),
              ),
              const SizedBox(height: 32),
              _isLoading ? const Center(child: CircularProgressIndicator()) : GoldGradientButton(text: 'Add Employee', onTap: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SmallIconBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}

class _ModalHeader extends StatelessWidget {
  final String title;
  const _ModalHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary));
  }
}

class _EmpFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  const _EmpFormField({required this.label, required this.controller, this.keyboardType = TextInputType.text});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
      const SizedBox(height: 4),
      TextFormField(
        controller: controller, keyboardType: keyboardType,
        decoration: AppTheme.inputDecoration('Enter $label'),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    ]);
  }
}

class _PasswordInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool visible;
  final VoidCallback onToggle;
  const _PasswordInputField({required this.controller, required this.visible, required this.onToggle});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('PASSWORD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
      const SizedBox(height: 4),
      TextFormField(
        controller: controller, obscureText: !visible,
        decoration: AppTheme.inputDecoration('Enter password', suffixIcon: IconButton(onPressed: onToggle, icon: Icon(visible ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18))),
        validator: (v) => v == null || v.length < 4 ? 'Min 4 chars' : null,
      ),
    ]);
  }
}

class _EmpDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const _EmpDropdown({required this.label, required this.value, required this.items, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
      const SizedBox(height: 4),
      DropdownButtonFormField<T>(
        value: value, items: items, onChanged: onChanged,
        decoration: AppTheme.inputDecoration('Select $label'),
      ),
    ]);
  }
}
