import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/inquiry_service.dart';
import '../../services/client_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EnquirySection extends StatefulWidget {
  final AppUser user;
  final Function(String) onToast;

  const EnquirySection({super.key, required this.user, required this.onToast});

  @override
  State<EnquirySection> createState() => _EnquirySectionState();
}

class _EnquirySectionState extends State<EnquirySection> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<dynamic> _allInquiries = [];
  List<dynamic> _filteredInquiries = [];
  List<Client> _clients = [];
  String _searchQuery = "";
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _applyFilters();
    });
    _initData();
  }

  Future<void> _initData() async {
    await Future.wait([
      _fetchInquiries(),
      _fetchClients(),
    ]);
  }

  Future<void> _fetchInquiries() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final data = await InquiryService.getAllInquiries();
    if (mounted) {
      setState(() {
        _allInquiries = data;
        _applyFilters();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchClients() async {
    try {
      final data = await ClientService.getAllClients();
      if (mounted) {
        setState(() {
          _clients = data.map((d) => Client.fromJson(d)).toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching clients: $e");
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredInquiries = _allInquiries.where((item) {
        final matchesSearch = (item['personName'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (item['client']?['name'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());
        
        if (!matchesSearch) return false;

        final status = (item['status'] ?? 'NEW').toString();
        if (_tabController.index == 1) return status == 'Onboarded';
        if (_tabController.index == 2) return (status == 'Not Onboarded' || status == 'NEW');
        
        return true;
      }).toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Inquiry Management',
              subtitle: 'Track and convert potential leads',
              action: GoldGradientButton(
                text: 'Add Inquiry',
                onTap: () => _showAddDialog(),
                width: 130,
                height: 40,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSearchAndFilters(),
            const SizedBox(height: 20),

            if (_isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(),
              ))
            else if (_filteredInquiries.isEmpty)
              _buildEmptyState()
            else
              _buildListView(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        SearchField(
          hint: 'Search by person or client...',
          onChanged: (val) {
            _searchQuery = val;
            _applyFilters();
          },
        ),
        const SizedBox(height: 16),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            indicator: BoxDecoration(
              gradient: goldGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Onboarded'),
              Tab(text: 'Pending'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredInquiries.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _InquiryCard(
          item: _filteredInquiries[i],
          onRefresh: _fetchInquiries,
          onToast: widget.onToast,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.question_answer_outlined, size: 70, color: AppColors.outlineVariant),
          const SizedBox(height: 16),
          Text(
            'No matching inquiries',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search or filters',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddEnquirySheet(
        clients: _clients,
        onSuccess: () {
          _fetchInquiries();
          widget.onToast("Inquiry created successfully!");
        },
      ),
    );
  }
}

class _InquiryCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onRefresh;
  final Function(String) onToast;

  const _InquiryCard({required this.item, required this.onRefresh, required this.onToast});

  @override
  Widget build(BuildContext context) {
    final status = (item['status'] ?? 'NEW').toString();
    final dateStr = item['dateTime'] ?? item['dateTimeString'] ?? '';
    final formattedDate = dateStr.isNotEmpty 
        ? DateFormat('dd MMM, yyyy').format(DateTime.parse(dateStr))
        : 'TBA';

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarWidget(
                initials: (item['personName'] ?? '?')[0].toUpperCase(),
                size: 40,
                fontSize: 15,
                color: AppColors.primaryContainer.withOpacity(0.3),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['personName'] ?? 'Unnamed',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.onSurface,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['client']?['name'] ?? 'Walk-in Client',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildBadge(status),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MetaItem(Icons.calendar_today_outlined, formattedDate),
              _MetaItem(Icons.how_to_reg_outlined, item['approachedVia'] ?? 'Contact'),
              _MetaItem(Icons.tag_rounded, '#${item['srNumber']}'),
            ],
          ),
          if (item['conclusion'] != null && item['conclusion'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
              ),
              child: Text(
                item['conclusion'],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GoldGradientButton(
                  text: 'Convert',
                  onTap: () => _handleConvert(context),
                  height: 34,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String status) {
    final isDone = status == 'Onboarded';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDone ? AppColors.chipDoneBg : AppColors.chipProgressBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
          color: isDone ? AppColors.chipDoneFg : AppColors.chipProgressFg,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Inquiry?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await InquiryService.deleteInquiry(item['srNumber']);
              if (ok) {
                onToast("Inquiry removed");
                onRefresh();
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConvert(BuildContext context) async {
    final ok = await InquiryService.convertToProject(item['srNumber']);
    if (ok) {
      onToast("Successfully converted to Project!");
      onRefresh();
    } else {
      onToast("Conversion failed");
    }
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaItem(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary.withOpacity(0.7)),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AddEnquirySheet extends StatefulWidget {
  final List<Client> clients;
  final VoidCallback onSuccess;
  const _AddEnquirySheet({required this.clients, required this.onSuccess});

  @override
  State<_AddEnquirySheet> createState() => _AddEnquirySheetState();
}

class _AddEnquirySheetState extends State<_AddEnquirySheet> {
  bool _isExistingClient = false;
  bool _isSaving = false;
  Client? _selectedClient;

  final _personNameCtrl = TextEditingController();
  final _conclusionCtrl = TextEditingController();
  String _approachedVia = "Call";

  // New Client Fields
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  Future<void> _save() async {
    if (_personNameCtrl.text.isEmpty) return;
    
    setState(() => _isSaving = true);
    
    final payload = {
      "personName": _personNameCtrl.text,
      "approachedVia": _approachedVia,
      "conclusion": _conclusionCtrl.text,
      "client": _isExistingClient 
        ? {"id": _selectedClient?.id} 
        : {
            "name": _nameCtrl.text,
            "email": _emailCtrl.text,
            "phone": _phoneCtrl.text,
            "address": _addressCtrl.text,
            "password": _passCtrl.text,
          },
    };

    final ok = await InquiryService.createInquiry(payload, _isExistingClient);
    if (ok && mounted) {
      widget.onSuccess();
      Navigator.pop(context);
    } else if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),
            Text('Add New Inquiry', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 8),
            Text('Capture details for the new prospect', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 24),

            // Toggle
            Row(
              children: [
                Expanded(
                  child: _ToggleBtn(
                    label: 'Existing Client',
                    active: _isExistingClient,
                    onTap: () => setState(() => _isExistingClient = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ToggleBtn(
                    label: 'New Client',
                    active: !_isExistingClient,
                    onTap: () => setState(() => _isExistingClient = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_isExistingClient) ...[
              const _FieldLabel('Select Client'),
              DropdownButtonFormField<Client>(
                initialValue: _selectedClient,
                decoration: AppTheme.inputDecoration('Choose client'),
                items: widget.clients.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => _selectedClient = v),
              ),
            ] else ...[
              const _FieldLabel('Client Details'),
              TextField(controller: _nameCtrl, decoration: AppTheme.inputDecoration('Client Name')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: _phoneCtrl, decoration: AppTheme.inputDecoration('Phone'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _emailCtrl, decoration: AppTheme.inputDecoration('Email'))),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: _addressCtrl, decoration: AppTheme.inputDecoration('Address')),
              const SizedBox(height: 12),
              TextField(controller: _passCtrl, decoration: AppTheme.inputDecoration('Portal Password'), obscureText: true),
            ],

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(),
            ),

            const _FieldLabel('Inquiry Details'),
            TextField(controller: _personNameCtrl, decoration: AppTheme.inputDecoration('Person Name')),
            const SizedBox(height: 12),
            const _FieldLabel('Approached Via'),
            DropdownButtonFormField<String>(
              initialValue: _approachedVia,
              decoration: AppTheme.inputDecoration('Select channel'),
              items: ['Call', 'Meeting', 'Reference', 'Website'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _approachedVia = v!),
            ),
            const SizedBox(height: 12),
            const _FieldLabel('Conclusion / Notes'),
            TextField(
              controller: _conclusionCtrl,
              maxLines: 3,
              decoration: AppTheme.inputDecoration('Initial discussion notes...'),
            ),

            const SizedBox(height: 32),
            GoldGradientButton(
              text: _isSaving ? 'Processing...' : 'Save Inquiry',
              onTap: _isSaving ? null : _save,
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ToggleBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryContainer.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.outlineVariant,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              color: active ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
