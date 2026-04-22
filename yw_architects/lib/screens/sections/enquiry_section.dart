import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/inquiry_service.dart';
import '../../services/client_service.dart';
import '../../services/quotation_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ── Status config matching web app ──────────────────────────────────────────
const _quotStatusCfg = {
  'DRAFT': {
    'bg': Color(0xFFF3F4F6),
    'fg': Color(0xFF374151),
    'dot': Color(0xFF9CA3AF),
    'label': 'Draft',
  },
  'SENT': {
    'bg': Color(0xFFDBEAFE),
    'fg': Color(0xFF1E40AF),
    'dot': Color(0xFF3B82F6),
    'label': 'Sent',
  },
  'ACCEPTED': {
    'bg': Color(0xFFDCFCE7),
    'fg': Color(0xFF14532D),
    'dot': Color(0xFF22C55E),
    'label': 'Accepted',
  },
};

class EnquirySection extends StatefulWidget {
  final AppUser user;
  final Function(String) onToast;

  const EnquirySection({super.key, required this.user, required this.onToast});

  @override
  State<EnquirySection> createState() => _EnquirySectionState();
}

class _EnquirySectionState extends State<EnquirySection>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<dynamic> _allInquiries = [];
  List<dynamic> _filteredInquiries = [];
  List<Client> _clients = [];
  String _searchQuery = '';
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
    await Future.wait([_fetchInquiries(), _fetchClients()]);
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
        setState(() => _clients = data.map((d) => Client.fromJson(d)).toList());
      }
    } catch (e) {
      debugPrint('Error fetching clients: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredInquiries = _allInquiries.where((item) {
        final matchesSearch =
            (item['personName'] ?? '').toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            (item['client']?['name'] ?? '').toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
        if (!matchesSearch) return false;
        final status = (item['status'] ?? 'NEW').toString();
        if (_tabController.index == 1) return status == 'Onboarded';
        if (_tabController.index == 2) return status != 'Onboarded';
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
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
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
        const SizedBox(height: 10),
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
          onView: _showDetailSheet,
          onEdit: _showEditSheet,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(
            Icons.question_answer_outlined,
            size: 70,
            color: AppColors.outlineVariant,
          ),
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
          widget.onToast('Inquiry created successfully!');
        },
      ),
    );
  }

  void _showDetailSheet(dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _InquiryDetailSheet(
        item: item,
        onRefresh: _fetchInquiries,
        onToast: widget.onToast,
      ),
    );
  }

  void _showEditSheet(dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditEnquirySheet(
        item: item,
        onSuccess: () {
          _fetchInquiries();
          widget.onToast('Inquiry updated successfully!');
        },
      ),
    );
  }
}

// ── Inquiry Card ─────────────────────────────────────────────────────────────
class _InquiryCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onRefresh;
  final Function(String) onToast;
  final Function(dynamic) onView;
  final Function(dynamic) onEdit;

  const _InquiryCard({
    required this.item,
    required this.onRefresh,
    required this.onToast,
    required this.onView,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final status = (item['status'] ?? 'NEW').toString();
    final dateStr = item['dateTime'] ?? item['dateTimeString'] ?? '';
    String formattedDate = 'TBA';
    if (dateStr.isNotEmpty) {
      try {
        formattedDate = DateFormat(
          'dd MMM, yyyy',
        ).format(DateTime.parse(dateStr));
      } catch (_) {}
    }

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarWidget(
                initials:
                    (item['personName'] != null &&
                        item['personName'].toString().trim().isNotEmpty)
                    ? item['personName'].toString().trim()[0].toUpperCase()
                    : '?',
                size: 40,
                fontSize: 15,
                color: AppColors.primaryContainer.withValues(alpha: 0.3),
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
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _MetaItem(Icons.calendar_today_outlined, formattedDate),
              _MetaItem(
                Icons.how_to_reg_outlined,
                item['approachedVia'] ?? 'Contact',
              ),
              _MetaItem(Icons.tag_rounded, '#${item['srNumber']}'),
            ],
          ),
          if (item['conclusion'] != null &&
              item['conclusion'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.1),
                ),
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
          // Action buttons — 3 buttons like the web app
          MediaQuery.of(context).size.width < 800
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => onView(item),
                            icon: const Icon(Icons.open_in_new_rounded, size: 15),
                            label: const Text('Details', overflow: TextOverflow.ellipsis),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              textStyle: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => onEdit(item),
                            icon: const Icon(Icons.edit_rounded, size: 15),
                            label: const Text('Edit', overflow: TextOverflow.ellipsis),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.onSurfaceVariant,
                              side: BorderSide(
                                color: AppColors.outlineVariant.withValues(alpha: 0.5),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              textStyle: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GoldGradientButton(
                      text: 'Convert to Project',
                      onTap: () => _handleConvert(context),
                      height: 38,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onView(item),
                        icon: const Icon(Icons.open_in_new_rounded, size: 15),
                        label: const Text('Details', overflow: TextOverflow.ellipsis),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onEdit(item),
                        icon: const Icon(Icons.edit_rounded, size: 15),
                        label: const Text('Edit', overflow: TextOverflow.ellipsis),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.onSurfaceVariant,
                          side: BorderSide(
                            color: AppColors.outlineVariant.withValues(alpha: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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

  Future<void> _handleConvert(BuildContext context) async {
    final ok = await InquiryService.convertToProject(item['srNumber']);
    if (ok) {
      onToast('Successfully converted to Project!');
      onRefresh();
    } else {
      onToast('Conversion failed');
    }
  }
}

// ── Inquiry Detail Sheet ─────────────────────────────────────────────────────
class _InquiryDetailSheet extends StatefulWidget {
  final dynamic item;
  final VoidCallback onRefresh;
  final Function(String) onToast;

  const _InquiryDetailSheet({
    required this.item,
    required this.onRefresh,
    required this.onToast,
  });

  @override
  State<_InquiryDetailSheet> createState() => _InquiryDetailSheetState();
}

class _InquiryDetailSheetState extends State<_InquiryDetailSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<Quotation> _quotations = [];
  bool _loadingQuots = true;
  bool _showAddForm = false;

  // Add quotation form controllers
  final _titleCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _validTill;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _fetchQuotations();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _titleCtrl.dispose();
    _budgetCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchQuotations() async {
    setState(() => _loadingQuots = true);
    final data = await QuotationService.getQuotationsByPreSale(
      widget.item['srNumber'],
    );
    if (mounted) {
      setState(() {
        _quotations = data.map((q) => Quotation.fromJson(q)).toList();
        _loadingQuots = false;
      });
    }
  }

  Future<void> _addQuotation() async {
    if (_titleCtrl.text.isEmpty || _budgetCtrl.text.isEmpty) return;
    setState(() => _saving = true);
    final ok = await QuotationService.createQuotation(widget.item['srNumber'], {
      'quotationDetails': _titleCtrl.text,
      'budget': double.tryParse(_budgetCtrl.text) ?? 0,
      if (_validTill != null) 'validTill': _validTill,
      'notes': _notesCtrl.text,
    });
    if (mounted) {
      setState(() => _saving = false);
      if (ok) {
        widget.onToast('Quotation added successfully!');
        _titleCtrl.clear();
        _budgetCtrl.clear();
        _notesCtrl.clear();
        _validTill = null;
        setState(() => _showAddForm = false);
        _fetchQuotations();
      } else {
        widget.onToast('Failed to add quotation');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final name = item['personName'] ?? '—';
    final clientName = item['client']?['name'] ?? '—';

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1A3A5C), const Color(0xFF0D2137)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '🏢 $clientName',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabs,
                  dividerColor: Colors.transparent,
                  indicatorColor: AppColors.primary,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  tabs: [
                    const Tab(text: '📋  Details'),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('📄  Quotations'),
                          if (_quotations.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_quotations.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [_buildDetailsTab(item), _buildQuotationsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(dynamic item) {
    String formattedDate = '—';
    final dateStr = item['dateTime']?.toString() ?? '';
    if (dateStr.isNotEmpty) {
      try {
        formattedDate = DateFormat(
          'd MMM yyyy',
        ).format(DateTime.parse(dateStr));
      } catch (_) {}
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('🔥  BASIC INFO', [
            _InfoRow('SR Number', '#${item['srNumber']}'),
            _InfoRow('Person Name', item['personName'] ?? '—'),
            _InfoRow('Client', item['client']?['name'] ?? '—'),
            _InfoRow('Email', item['client']?['email'] ?? item['email'] ?? '—'),
            _InfoRow('Phone', item['client']?['phone']?.toString() ?? '—'),
            _InfoRow('Date', formattedDate),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('📬  ENQUIRY INFO', [
            _InfoRow('Approached Via', item['approachedVia'] ?? '—'),
            _InfoRow('Status', item['status'] ?? '—'),
            if (item['conclusion'] != null &&
                item['conclusion'].toString().isNotEmpty)
              _InfoRow('Conclusion', item['conclusion']),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotationsTab() {
    return Column(
      children: [
        // Header with add button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quotations${_quotations.isNotEmpty ? ' (${_quotations.length})' : ''}',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.onSurface,
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _showAddForm = !_showAddForm),
                icon: Icon(
                  _showAddForm ? Icons.close_rounded : Icons.add_rounded,
                  size: 18,
                ),
                label: Text(_showAddForm ? 'Cancel' : '+ Add Quotation'),
                style: TextButton.styleFrom(
                  foregroundColor: _showAddForm
                      ? AppColors.error
                      : AppColors.primary,
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Add Quotation form
        if (_showAddForm) _buildAddQuotationForm(),

        // Quotation list
        Expanded(
          child: _loadingQuots
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _quotations.isEmpty
              ? _buildNoQuotationsState()
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _quotations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _QuotationCard(
                    quotation: _quotations[i],
                    onDelete: () async {
                      final ok = await QuotationService.deleteQuotation(
                        _quotations[i].id,
                      );
                      if (ok) {
                        widget.onToast('Quotation deleted');
                        _fetchQuotations();
                      }
                    },
                    onAccept: () async {
                      final ok = await QuotationService.markAsAccepted(
                        _quotations[i].id,
                      );
                      if (ok) {
                        widget.onToast('Quotation accepted!');
                        _fetchQuotations();
                      }
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAddQuotationForm() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Quotation',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleCtrl,
                  decoration: AppTheme.inputDecoration('Title *'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _budgetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: AppTheme.inputDecoration('Amount (₹) *'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            maxLines: 2,
            decoration: AppTheme.inputDecoration('Notes (optional)'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _showAddForm = false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _saving ? null : _addQuotation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _saving ? 'Saving...' : 'Save Quotation',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoQuotationsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 56,
            color: AppColors.outlineVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No quotations yet',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Click "+ Add Quotation" to create one',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quotation Card ────────────────────────────────────────────────────────────
class _QuotationCard extends StatelessWidget {
  final Quotation quotation;
  final VoidCallback onDelete;
  final VoidCallback onAccept;

  const _QuotationCard({
    required this.quotation,
    required this.onDelete,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = _quotStatusCfg[quotation.status] ?? _quotStatusCfg['DRAFT']!;
    final isAccepted = quotation.status == 'ACCEPTED';

    String formattedDate = '—';
    if (quotation.createdAt != null) {
      try {
        formattedDate = DateFormat(
          'd MMM yyyy, h:mm a',
        ).format(DateTime.parse(quotation.createdAt!));
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAccepted
              ? const Color(0xFF22C55E).withValues(alpha: 0.4)
              : AppColors.outlineVariant.withValues(alpha: 0.3),
          width: isAccepted ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#${quotation.id}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  quotation.quotationNumber,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cfg['bg'] as Color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: cfg['dot'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      quotation.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: cfg['fg'] as Color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _QuotMeta(Icons.calendar_today_outlined, formattedDate),
              const SizedBox(width: 16),
              if (!quotation.sended)
                _QuotMeta(Icons.send_rounded, 'Not Sent')
              else
                _QuotMeta(
                  Icons.check_rounded,
                  'Sent',
                  color: const Color(0xFF1E40AF),
                ),
              if (quotation.accepted) ...[
                const SizedBox(width: 16),
                _QuotMeta(
                  Icons.check_circle_outlined,
                  'Accepted',
                  color: const Color(0xFF14532D),
                ),
              ],
            ],
          ),
          if (quotation.notes != null && quotation.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              quotation.notes!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (!isAccepted)
                TextButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: Color(0xFF14532D),
                  ),
                  label: Text(
                    'Accept',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF14532D),
                      fontSize: 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    backgroundColor: const Color(0xFF14532D).withValues(alpha: 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              const Spacer(),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                  color: AppColors.error,
                ),
                label: Text(
                  'Delete',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  backgroundColor: AppColors.error.withValues(alpha: 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuotMeta extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _QuotMeta(this.icon, this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: c),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: c,
          ),
        ),
      ],
    );
  }
}

// ── Edit Enquiry Sheet ────────────────────────────────────────────────────────
class _EditEnquirySheet extends StatefulWidget {
  final dynamic item;
  final VoidCallback onSuccess;

  const _EditEnquirySheet({required this.item, required this.onSuccess});

  @override
  State<_EditEnquirySheet> createState() => _EditEnquirySheetState();
}

class _EditEnquirySheetState extends State<_EditEnquirySheet> {
  late TextEditingController _personNameCtrl;
  late TextEditingController _conclusionCtrl;
  late String _approachedVia;
  late String _status;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _personNameCtrl = TextEditingController(
      text: widget.item['personName'] ?? '',
    );
    _conclusionCtrl = TextEditingController(
      text: widget.item['conclusion'] ?? '',
    );
    _approachedVia = widget.item['approachedVia'] ?? 'Call';
    _status = widget.item['status'] ?? 'NEW';
  }

  @override
  void dispose() {
    _personNameCtrl.dispose();
    _conclusionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await InquiryService.updateInquiry(widget.item['srNumber'], {
      'personName': _personNameCtrl.text,
      'approachedVia': _approachedVia,
      'status': _status,
      'conclusion': _conclusionCtrl.text,
    });
    if (mounted) {
      setState(() => _saving = false);
      if (ok) {
        widget.onSuccess();
        Navigator.pop(context);
      }
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
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Edit Inquiry',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Update the details for this inquiry',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Read-only: Client
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.business_outlined,
                    size: 18,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CLIENT (read-only)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.outline,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          widget.item['client']?['name'] ?? '—',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _FieldLabel('Person Name'),
            TextField(
              controller: _personNameCtrl,
              decoration: AppTheme.inputDecoration('Person Name'),
            ),
            const SizedBox(height: 12),
            _FieldLabel('Approached Via'),
            DropdownButtonFormField<String>(
              initialValue: [
                'Call',
                'Meeting',
                'Reference',
                'Website',
              ].contains(_approachedVia)
                  ? _approachedVia
                  : 'Call',
              decoration: AppTheme.inputDecoration('Select channel'),
              items: [
                'Call',
                'Meeting',
                'Reference',
                'Website',
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _approachedVia = v!),
            ),
            const SizedBox(height: 12),
            _FieldLabel('Status'),
            DropdownButtonFormField<String>(
              initialValue: ['NEW', 'Onboarded', 'Not Onboarded'].contains(_status)
                  ? _status
                  : 'NEW',
              decoration: AppTheme.inputDecoration('Select status'),
              items: [
                'NEW',
                'Onboarded',
                'Not Onboarded',
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 12),
            _FieldLabel('Conclusion / Notes'),
            TextField(
              controller: _conclusionCtrl,
              maxLines: 3,
              decoration: AppTheme.inputDecoration('Enter notes...'),
            ),
            const SizedBox(height: 32),
            GoldGradientButton(
              text: _saving ? 'Saving...' : 'Save Changes',
              onTap: _saving ? null : _save,
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Row helper ──────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.outline,
              letterSpacing: 0.5,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────
class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaItem(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary.withValues(alpha: 0.7)),
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

// ── Add Enquiry Sheet (unchanged) ────────────────────────────────────────────
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
  String _approachedVia = 'Call';

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  Future<void> _save() async {
    if (_personNameCtrl.text.isEmpty) return;
    setState(() => _isSaving = true);

    final payload = {
      'personName': _personNameCtrl.text,
      'approachedVia': _approachedVia,
      'conclusion': _conclusionCtrl.text,
      'client': _isExistingClient
          ? {'id': _selectedClient?.id}
          : {
              'name': _nameCtrl.text,
              'email': _emailCtrl.text,
              'phone': _phoneCtrl.text,
              'address': _addressCtrl.text,
              'password': _passCtrl.text,
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
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Add New Inquiry',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Capture details for the new prospect',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
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
                items: widget.clients
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedClient = v),
              ),
            ] else ...[
              const _FieldLabel('Client Details'),
              TextField(
                controller: _nameCtrl,
                decoration: AppTheme.inputDecoration('Client Name'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      maxLength: 10,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: AppTheme.inputDecoration(
                        'Phone',
                      ).copyWith(counterText: ''),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _emailCtrl,
                      decoration: AppTheme.inputDecoration('Email'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressCtrl,
                decoration: AppTheme.inputDecoration('Address'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                decoration: AppTheme.inputDecoration('Portal Password'),
                obscureText: true,
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(),
            ),
            const _FieldLabel('Inquiry Details'),
            TextField(
              controller: _personNameCtrl,
              decoration: AppTheme.inputDecoration('Person Name'),
            ),
            const SizedBox(height: 12),
            const _FieldLabel('Approached Via'),
            DropdownButtonFormField<String>(
              initialValue: _approachedVia,
              decoration: AppTheme.inputDecoration('Select channel'),
              items: [
                'Call',
                'Meeting',
                'Reference',
                'Website',
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _approachedVia = v!),
            ),
            const SizedBox(height: 12),
            const _FieldLabel('Conclusion / Notes'),
            TextField(
              controller: _conclusionCtrl,
              maxLines: 3,
              decoration: AppTheme.inputDecoration(
                'Initial discussion notes...',
              ),
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
  const _ToggleBtn({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primaryContainer.withValues(alpha: 0.1)
              : Colors.transparent,
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
