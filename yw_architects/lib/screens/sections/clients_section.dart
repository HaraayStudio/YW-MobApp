import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/client_service.dart';

// ══════════════════════════════════════════════════════════════
//  CLIENTS SECTION
// ══════════════════════════════════════════════════════════════

class _Client {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String pan;
  final String gst;
  final String initials;

  const _Client({
    this.id = 0,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.pan,
    required this.gst,
    required this.initials,
  });

  factory _Client.fromJson(Map<String, dynamic> json) {
    final nameStr = json['name']?.toString() ?? 'Unknown';
    final parts = nameStr.trim().split(' ');
    String ini = '';
    if (parts.isNotEmpty && parts[0].isNotEmpty) ini += parts[0][0];
    if (parts.length > 1 && parts[1].isNotEmpty) ini += parts[1][0];
    if (ini.isEmpty) ini = 'C';

    return _Client(
      id: json['id'] as int? ?? 0,
      name: nameStr,
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      pan: json['PAN']?.toString() ?? json['pan']?.toString() ?? '',
      gst:
          json['GSTCertificate']?.toString() ??
          json['gstcertificate']?.toString() ??
          '',
      initials: ini.toUpperCase(),
    );
  }
}

class ClientsSection extends StatefulWidget {
  final Function(String) onToast;
  const ClientsSection({super.key, required this.onToast});

  @override
  State<ClientsSection> createState() => _ClientsSectionState();
}

class _ClientsSectionState extends State<ClientsSection> {
  _Client? _selectedClient;
  final _searchCtrl = TextEditingController();

  List<_Client> _clients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  Future<void> _fetchClients() async {
    setState(() => _isLoading = true);
    try {
      final rawData = await ClientService.getAllClients();
      final parsed = rawData
          .map((e) => _Client.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _clients = parsed;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        widget.onToast('Failed to load clients: $e');
      }
    }
  }

  List<_Client> get _filtered {
    var list = _clients.toList();
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (c) =>
                c.name.toLowerCase().contains(q) ||
                c.email.toLowerCase().contains(q) ||
                c.phone.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openAddModal() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddClientModal(onToast: widget.onToast),
    );
    if (result == true) {
      _fetchClients();
    }
  }

  Future<void> _deleteClient(_Client client) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Client?'),
        content: Text('Are you sure you want to delete ${client.name}?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() => _isLoading = true);
      final success = await ClientService.deleteClient(client.id);
      if (success) {
        widget.onToast("Client deleted successfully.");
        _selectedClient = null;
        _fetchClients();
      } else {
        widget.onToast("Failed to delete client.");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      widget.onToast("Error deleting client: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedClient != null) return _buildProfile(_selectedClient!);
    return _buildList();
  }

  Widget _buildList() {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            CardSkeleton(),
            CardSkeleton(),
            CardSkeleton(),
            CardSkeleton(),
            CardSkeleton(),
          ],
        ),
      );
    }
    final list = _filtered;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SectionHeader(
                    title: 'Clients',
                    subtitle: '${list.length} active clients',
                  ),
                ),
                GestureDetector(
                  onTap: _openAddModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: goldGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_add_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurface,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search clients...',
                  hintStyle: TextStyle(color: AppColors.outline, fontSize: 14),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (list.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    'No clients found',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                ),
              ),

            // Client cards
            ...list.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ClientCard(
                  client: c,
                  onTap: () => setState(() => _selectedClient = c),
                  onToast: widget.onToast,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(_Client c) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  AvatarWidget(initials: c.initials, size: 68, fontSize: 22),
                  const SizedBox(height: 10),
                  Text(
                    c.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Client ID: CL-${c.id}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ActionBtn(
                        label: 'Call',
                        icon: Icons.call_rounded,
                        onTap: () => widget.onToast('Calling ${c.name}...'),
                        gradient: true,
                      ),
                      const SizedBox(width: 10),
                      _ActionBtn(
                        label: 'Email',
                        icon: Icons.mail_rounded,
                        onTap: () => widget.onToast('Opening email...'),
                        gradient: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            CardContainer(
              child: Column(
                children:
                    [
                          _InfoRow(Icons.mail_rounded, 'Email', c.email),
                          _InfoRow(Icons.phone_rounded, 'Phone', c.phone),
                          _InfoRow(
                            Icons.location_on_rounded,
                            'Address',
                            c.address.isEmpty ? 'N/A' : c.address,
                          ),
                          _InfoRow(
                            Icons.receipt_rounded,
                            'PAN',
                            c.pan.isEmpty ? 'N/A' : c.pan,
                          ),
                          _InfoRow(
                            Icons.receipt_long_rounded,
                            'GST',
                            c.gst.isEmpty ? 'N/A' : c.gst,
                          ),
                        ]
                        .map(
                          (w) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: w,
                          ),
                        )
                        .toList(),
              ),
            ),
            const SizedBox(height: 14),

            CardContainer(
              child: GestureDetector(
                onTap: () => _deleteClient(c),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.delete_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Delete Client',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
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
}

// ══════════════════════════════════════════════════════════════
//  ADD CLIENT MODAL
// ══════════════════════════════════════════════════════════════
class _AddClientModal extends StatefulWidget {
  final Function(String) onToast;
  const _AddClientModal({required this.onToast});

  @override
  State<_AddClientModal> createState() => _AddClientModalState();
}

class _AddClientModalState extends State<_AddClientModal> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();
  final _panCtrl = TextEditingController();

  bool _pwVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _addressCtrl.dispose();
    _gstCtrl.dispose();
    _panCtrl.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_nameCtrl.text.trim().isEmpty) return 'Name is required';
    if (_emailCtrl.text.trim().isEmpty) return 'Email is required';
    if (!_emailCtrl.text.contains('@')) return 'Enter a valid email';
    if (_phoneCtrl.text.trim().isEmpty) return 'Phone number is required';
    if (_passwordCtrl.text.length < 6)
      return 'Password must be at least 6 characters';
    return null;
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': int.tryParse(_phoneCtrl.text.trim()) ?? 0,
      'address': _addressCtrl.text.trim(),
      'GSTCertificate': _gstCtrl.text.trim().toUpperCase(),
      'PAN': _panCtrl.text.trim().toUpperCase(),
      'password': _passwordCtrl.text.trim(),
      'role': 'CLIENT',
    };
  }

  Future<void> _submit() async {
    final error = _validate();
    if (error != null) {
      widget.onToast(error);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final success = await ClientService.createClient(_buildPayload());
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pop(context, true);
          widget.onToast('Client added successfully!');
        } else {
          widget.onToast('Failed to add client. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        widget.onToast('Network error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Client',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.onSurfaceVariant,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _SectionLabel('Basic Info'),
            const SizedBox(height: 12),
            _FormField(
              label: 'FULL NAME',
              hint: 'Anand Kapoor',
              controller: _nameCtrl,
            ),
            const SizedBox(height: 12),
            _FormField(
              label: 'EMAIL',
              hint: 'client@email.com',
              controller: _emailCtrl,
              keyboard: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _FormField(
              label: 'PHONE',
              hint: '9876543210',
              controller: _phoneCtrl,
              keyboard: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            _FormField(
              label: 'ADDRESS',
              hint: 'City, State',
              controller: _addressCtrl,
            ),
            const SizedBox(height: 12),
            _PasswordField(
              controller: _passwordCtrl,
              visible: _pwVisible,
              onToggle: () => setState(() => _pwVisible = !_pwVisible),
            ),
            const SizedBox(height: 20),

            _SectionLabel('Registration Docs'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _FormField(
                    label: 'PAN',
                    hint: 'ABCDE1234F',
                    controller: _panCtrl,
                    maxLength: 10,
                    inputFormatters: [UpperCaseTextFormatter()],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormField(
                    label: 'GST NUMBER',
                    hint: '22AAAAA0000A1Z5',
                    controller: _gstCtrl,
                    maxLength: 15,
                    inputFormatters: [UpperCaseTextFormatter()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : GoldGradientButton(
                    text: 'Add Client',
                    icon: Icons.person_add_rounded,
                    onTap: _submit,
                  ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  REUSABLE WIDGETS FOR THIS FILE
// ══════════════════════════════════════════════════════════════

class _ClientCard extends StatelessWidget {
  final _Client client;
  final VoidCallback onTap;
  final Function(String) onToast;

  const _ClientCard({
    required this.client,
    required this.onTap,
    required this.onToast,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CardContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AvatarWidget(initials: client.initials, size: 50, fontSize: 16),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.email_rounded,
                        size: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        client.email.isNotEmpty ? client.email : 'No Email',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_rounded,
                        size: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        client.phone.isNotEmpty ? client.phone : 'No Phone',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 4),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.primaryContainer, width: 3),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}

class _DropdownLabel extends StatelessWidget {
  final String text;
  const _DropdownLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.outline,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboard;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboard,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DropdownLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.outline, fontSize: 13),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryContainer,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            isDense: true,
            counterText: '',
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool visible;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.visible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DropdownLabel('PASSWORD'),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: !visible,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: const TextStyle(color: AppColors.outline, fontSize: 13),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryContainer,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            isDense: true,
            suffixIcon: IconButton(
              icon: Icon(
                visible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool gradient;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: gradient ? null : AppColors.surfaceContainerHigh,
        gradient: gradient ? goldGradient : null,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: gradient ? Colors.white : AppColors.onSurface,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: gradient ? Colors.white : AppColors.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    return GestureDetector(onTap: onTap, child: child);
  }
}

Widget _InfoRow(IconData icon, String label, String val) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 16),
      ),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            val,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ],
  );
}
