import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yw_architects/theme/app_theme.dart';
import 'package:yw_architects/widgets/common_widgets.dart';
import 'package:yw_architects/utils/responsive.dart';
import 'package:yw_architects/models/app_models.dart';
import 'package:yw_architects/services/employee_service.dart';
import 'package:yw_architects/screens/sections/employee/models/employee_models.dart';
import 'package:intl/intl.dart';

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
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          AvatarWidget(initials: e.initials, size: 48.w, fontSize: 15.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(e.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp, color: AppColors.onSurface), overflow: TextOverflow.ellipsis)),
                    GoldChip(
                        text: e.status, 
                        bg: e.status.toLowerCase() == 'active' ? AppColors.chipDoneBg : AppColors.chipHoldBg, 
                        fg: e.status.toLowerCase() == 'active' ? AppColors.chipDoneFg : AppColors.chipHoldFg),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(e.roleLabel, style: TextStyle(fontSize: 12.sp, color: AppColors.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                SizedBox(height: 8.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Icon(Icons.folder_open_rounded, size: 12.w, color: AppColors.onSurfaceVariant),
                      SizedBox(width: 4.w),
                      Text('${e.projects} projects', style: TextStyle(fontSize: 11.sp, color: AppColors.onSurfaceVariant)),
                      SizedBox(width: 12.w),
                      Icon(Icons.calendar_today_rounded, size: 12.w, color: AppColors.onSurfaceVariant),
                      SizedBox(width: 4.w),
                      Text('Since ${e.since}', style: TextStyle(fontSize: 11.sp, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
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
      padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 12.h, bottom: MediaQuery.of(context).viewInsets.bottom + 24.h),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(28.w))),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(10.w)))),
              SizedBox(height: 20.h),
              const _ModalHeader(title: 'Register New Employee'),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(child: _EmpFormField(label: 'FIRST NAME', controller: _fNameCtrl)),
                  SizedBox(width: 16.w),
                  Expanded(child: _EmpFormField(label: 'LAST NAME', controller: _lNameCtrl)),
                ],
              ),
              SizedBox(height: 16.h),
              _EmpFormField(label: 'EMAIL ADDRESS', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
              SizedBox(height: 16.h),
              _EmpFormField(label: 'PHONE NUMBER', controller: _phoneCtrl, keyboardType: TextInputType.phone, maxLength: 10, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              SizedBox(height: 16.h),
              _PasswordInputField(controller: _passCtrl, visible: _passVisible, onToggle: () => setState(() => _passVisible = !_passVisible)),
              SizedBox(height: 16.h),
              _EmpDropdown<UserRole>(
                label: 'OFFICIAL ROLE',
                value: _selectedRole,
                items: roleMap.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value.name, style: TextStyle(fontSize: 14.sp)))).toList(),
                onChanged: (v) => setState(() => _selectedRole = v!),
              ),
              SizedBox(height: 32.h),
              _isLoading ? const Center(child: CircularProgressIndicator()) : GoldGradientButton(text: 'Add Employee', onTap: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

class EditEmployeeModal extends StatefulWidget {
  final EmployeeModel employee;
  final Function(String) onToast;
  final VoidCallback onSuccess;

  const EditEmployeeModal({
    super.key,
    required this.employee,
    required this.onToast,
    required this.onSuccess,
  });

  @override
  State<EditEmployeeModal> createState() => _EditEmployeeModalState();
}

class _EditEmployeeModalState extends State<EditEmployeeModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fNameCtrl;
  late TextEditingController _lNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _adharCtrl;
  late TextEditingController _panCtrl;
  late TextEditingController _birthDateCtrl;
  late TextEditingController _joinDateCtrl;
  late TextEditingController _leaveDateCtrl;

  late UserRole _selectedRole;
  late String _selectedGender;
  late String _selectedBloodGroup;
  late String _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _fNameCtrl = TextEditingController(text: e.firstName);
    _lNameCtrl = TextEditingController(text: e.lastName);
    _emailCtrl = TextEditingController(text: e.email);
    _phoneCtrl = TextEditingController(text: e.phone);
    _adharCtrl = TextEditingController(text: e.adharNumber);
    _panCtrl = TextEditingController(text: e.panNumber);
    _birthDateCtrl = TextEditingController(text: e.birthDate);
    _joinDateCtrl = TextEditingController(text: e.joinDate);
    _leaveDateCtrl = TextEditingController(text: e.leaveDate);

    _selectedRole = e.role;
    
    // Safety check for Gender
    const genderOptions = ['Male', 'Female', 'Other'];
    _selectedGender = genderOptions.contains(e.gender) ? e.gender : 'Male';
    
    // Safety check for Blood Group
    const bloodOptions = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
    _selectedBloodGroup = bloodOptions.contains(e.bloodGroup) ? e.bloodGroup : 'A+';
    
    _selectedStatus = e.status.toUpperCase();
  }

  @override
  void dispose() {
    _fNameCtrl.dispose();
    _lNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _adharCtrl.dispose();
    _panCtrl.dispose();
    _birthDateCtrl.dispose();
    _joinDateCtrl.dispose();
    _leaveDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final payload = {
        'firstName': _fNameCtrl.text.trim(),
        'lastName': _lNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'adharNumber': _adharCtrl.text.trim(),
        'panNumber': _panCtrl.text.trim(),
        'birthDate': _birthDateCtrl.text.trim(),
        'joinDate': _joinDateCtrl.text.trim(),
        'leaveDate': _leaveDateCtrl.text.trim(),
        'gender': _selectedGender,
        'bloodGroup': _selectedBloodGroup,
        'role': roleToBackend(_selectedRole),
        'status': _selectedStatus,
      };

      final success = await EmployeeService.updateEmployee(widget.employee.id, payload);
      if (success) {
        widget.onToast("Employee updated successfully!");
        widget.onSuccess();
        if (mounted) Navigator.pop(context);
      } else {
        widget.onToast("Failed to update employee.");
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
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: 24
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface, 
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))
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
                  width: 40, height: 4, 
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant, 
                    borderRadius: BorderRadius.circular(10)
                  )
                )
              ),
              const SizedBox(height: 20),
              const _ModalHeader(title: 'Edit Employee Profile'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _EmpFormField(label: 'FIRST NAME', controller: _fNameCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _EmpFormField(label: 'LAST NAME', controller: _lNameCtrl)),
                ],
              ),
              const SizedBox(height: 16),
              _EmpFormField(label: 'EMAIL ADDRESS', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _EmpFormField(label: 'PHONE NUMBER', controller: _phoneCtrl, keyboardType: TextInputType.phone, maxLength: 10, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _EmpFormField(
                      label: 'AADHAAR NUMBER',
                      controller: _adharCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _EmpFormField(
                      label: 'PAN NUMBER',
                      controller: _panCtrl,
                      maxLength: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _EmpDropdown<String>(
                      label: 'GENDER',
                      value: _selectedGender,
                      items: ['Male', 'Female', 'Other']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedGender = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _EmpDropdown<String>(
                      label: 'BLOOD GROUP',
                      value: _selectedBloodGroup,
                      items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedBloodGroup = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _EmpDateField(
                      label: 'BIRTH DATE',
                      controller: _birthDateCtrl,
                      context: context,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _EmpDateField(
                      label: 'JOIN DATE',
                      controller: _joinDateCtrl,
                      context: context,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _EmpDropdown<UserRole>(
                label: 'OFFICIAL ROLE',
                value: _selectedRole,
                items: roleMap.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedRole = v!),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GoldGradientButton(text: 'Save Changes', onTap: _submit),
              // Add space for keyboard
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        ),
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
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  const _EmpFormField({required this.label, required this.controller, this.keyboardType = TextInputType.text, this.maxLength, this.inputFormatters});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.5),
        ),
      ),
      const SizedBox(height: 4),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 13),
        decoration: AppTheme.inputDecoration('Enter $label').copyWith(
          counterText: '',
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
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
      const Text('PASSWORD',
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant)),
      const SizedBox(height: 4),
      TextFormField(
        controller: controller,
        obscureText: !visible,
        style: const TextStyle(fontSize: 13),
        decoration: AppTheme.inputDecoration('Enter password').copyWith(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
                visible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                size: 18),
          ),
        ),
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
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant),
        ),
      ),
      const SizedBox(height: 4),
      DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        style: const TextStyle(fontSize: 13, color: AppColors.onSurface),
        decoration: AppTheme.inputDecoration('Select $label').copyWith(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    ]);
  }
}

class _EmpDateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final BuildContext context;

  const _EmpDateField({
    required this.label,
    required this.controller,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          readOnly: true,
          style: const TextStyle(fontSize: 13),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      onSurface: AppColors.onSurface,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              controller.text = DateFormat('yyyy-MM-dd').format(date);
            }
          },
          decoration: AppTheme.inputDecoration('Select $label').copyWith(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
}
