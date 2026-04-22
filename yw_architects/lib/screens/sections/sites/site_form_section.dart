import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class SiteFormSection extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(Map<String, dynamic>) onSubmit;

  const SiteFormSection({super.key, required this.onCancel, required this.onSubmit});

  @override
  State<SiteFormSection> createState() => _SiteFormSectionState();
}

class _SiteFormSectionState extends State<SiteFormSection> {
  final _formKey = GlobalKey<FormState>();
  final _siteNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  
  String _selectedStatus = 'PLANNING';
  String _selectedPriority = 'MEDIUM';
  int? _selectedProjectId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Add New Site",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildLabel("SITE NAME"),
              _buildTextField(_siteNameCtrl, "Enter site name (e.g. Building A)"),
              
              const SizedBox(height: 16),
              _buildLabel("LINK TO PROJECT ID"),
              _buildTextField(
                TextEditingController(text: _selectedProjectId?.toString() ?? ''),
                "Project ID",
                isNumber: true,
                onChanged: (val) => _selectedProjectId = int.tryParse(val),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("STATUS"),
                        _buildDropdown(
                          ['PLANNING', 'IN_PROGRESS', 'COMPLETED', 'ON_HOLD'],
                          _selectedStatus,
                          (val) => setState(() => _selectedStatus = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("PRIORITY"),
                        _buildDropdown(
                          ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'],
                          _selectedPriority,
                          (val) => setState(() => _selectedPriority = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              _buildLabel("BUILT UP AREA (sq.mt)"),
              _buildTextField(_areaCtrl, "0.0", isNumber: true),

              const SizedBox(height: 16),
              _buildLabel("CITY"),
              _buildTextField(_cityCtrl, "City name"),

              const SizedBox(height: 16),
              _buildLabel("ADDRESS"),
              _buildTextField(_addressCtrl, "Full site address", maxLines: 3),

              const SizedBox(height: 32),
              GoldGradientButton(
                text: "Create Site",
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSubmit({
                      'siteName': _siteNameCtrl.text,
                      'projectId': _selectedProjectId,
                      'status': _selectedStatus,
                      'priority': _selectedPriority,
                      'builtUpArea': double.tryParse(_areaCtrl.text) ?? 0.0,
                      'city': _cityCtrl.text,
                      'address': _addressCtrl.text,
                    });
                  }
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.outline,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, {bool isNumber = false, int maxLines = 1, Function(String)? onChanged}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      onChanged: onChanged,
      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.outline.withValues(alpha: 0.5)),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (val) => val == null || val.isEmpty ? "Field required" : null,
    );
  }

  Widget _buildDropdown(List<String> items, String current, Function(String?) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          isExpanded: true,
          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
