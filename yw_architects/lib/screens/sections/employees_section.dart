import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class EmployeesSection extends StatefulWidget {
  final Function(String) onToast;

  const EmployeesSection({super.key, required this.onToast});

  @override
  State<EmployeesSection> createState() => _EmployeesSectionState();
}

class _EmployeesSectionState extends State<EmployeesSection> {
  String? _selectedEmployee;

  final _employees = [
    {'name': 'Rahul Kapoor', 'role': 'Senior Architect', 'dept': 'Architecture', 'status': 'Active', 'since': 'Jan 2021', 'email': 'rahul@ywarchitects.com', 'init': 'RK', 'projects': 3},
    {'name': 'Priya Singh', 'role': 'Interior Designer', 'dept': 'Interior', 'status': 'Active', 'since': 'Mar 2022', 'email': 'priya@ywarchitects.com', 'init': 'PS', 'projects': 2},
    {'name': 'Amit Joshi', 'role': 'Site Engineer', 'dept': 'Construction', 'status': 'Active', 'since': 'Jul 2020', 'email': 'amit@ywarchitects.com', 'init': 'AJ', 'projects': 4},
    {'name': 'Varun Rao', 'role': '3D Visualizer', 'dept': 'Design', 'status': 'Active', 'since': 'Sep 2022', 'email': 'varun@ywarchitects.com', 'init': 'VR', 'projects': 3},
    {'name': 'Kavya Rao', 'role': 'Junior Architect', 'dept': 'Architecture', 'status': 'Active', 'since': 'Jun 2023', 'email': 'kavya@ywarchitects.com', 'init': 'KR', 'projects': 2},
    {'name': 'Meera Nair', 'role': 'Junior Architect', 'dept': 'Architecture', 'status': 'On Leave', 'since': 'Dec 2023', 'email': 'meera@ywarchitects.com', 'init': 'MN', 'projects': 1},
    {'name': 'Dev Patel', 'role': 'Site Engineer', 'dept': 'Construction', 'status': 'Active', 'since': 'Feb 2024', 'email': 'dev@ywarchitects.com', 'init': 'DP', 'projects': 1},
  ];

  @override
  Widget build(BuildContext context) {
    if (_selectedEmployee != null) return _buildProfile(_selectedEmployee!);
    return _buildList();
  }

  Widget _buildList() {
    final tabs = ['All', 'Architecture', 'Interior', 'Construction', 'Design'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: SectionHeader(title: 'Employees', subtitle: '${_employees.length} team members')),
              GestureDetector(
                onTap: () => _showAddEmployeeModal(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(gradient: goldGradient, borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]),
                  child: const Row(children: [Icon(Icons.person_add_rounded, color: Colors.white, size: 16), SizedBox(width: 4), Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search
          Container(
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search employees...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 20),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: i == 0 ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(tabs[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: i == 0 ? Colors.white : AppColors.outline)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          ..._employees.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedEmployee = e['name'] as String),
              child: CardContainer(
                child: Row(
                  children: [
                    AvatarWidget(initials: e['init'] as String, size: 52, fontSize: 16),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(e['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.onSurface)),
                            const SizedBox(width: 8),
                            StatusChip(status: e['status'] as String),
                          ]),
                          const SizedBox(height: 2),
                          Text(e['role'] as String, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: 6),
                          Row(children: [
                            const Icon(Icons.folder_open_rounded, size: 12, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text('${e['projects']} projects', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                            const SizedBox(width: 10),
                            const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text('Since ${e['since']}', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                          ]),
                        ],
                      ),
                    ),
                    Column(children: [
                      GestureDetector(
                        onTap: () => widget.onToast('Calling ${e['name']}...'),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
                          child: const Icon(Icons.call_rounded, color: AppColors.primary, size: 18),
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => widget.onToast('Email opened!'),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
                          child: const Icon(Icons.mail_rounded, color: AppColors.primary, size: 18),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildProfile(String name) {
    final info = [
      {'icon': Icons.mail_rounded, 'label': 'Email', 'val': 'rahul@ywarchitects.com'},
      {'icon': Icons.phone_rounded, 'label': 'Phone', 'val': '+91 98765 43210'},
      {'icon': Icons.badge_rounded, 'label': 'Employee ID', 'val': 'YW-2021-001'},
      {'icon': Icons.home_work_rounded, 'label': 'Department', 'val': 'Architecture'},
      {'icon': Icons.school_rounded, 'label': 'Qualification', 'val': 'B.Arch, CEPT University'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => setState(() => _selectedEmployee = null),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
            label: const Text('Back', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),

          // Profile Hero
          CardContainer(
            child: Column(
              children: [
                const AvatarWidget(initials: 'RK', size: 72, fontSize: 22),
                const SizedBox(height: 12),
                Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
                const Text('Senior Architect · Architecture Dept', style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 12),
                const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  GoldChip(text: 'Active', bg: AppColors.chipDoneBg, fg: AppColors.chipDoneFg),
                  SizedBox(width: 8),
                  Chip(label: Text('SINCE JAN 2021', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.5)), backgroundColor: Color(0x26B8952A), padding: EdgeInsets.zero),
                ]),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  GestureDetector(
                    onTap: () => widget.onToast('Calling...'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(gradient: goldGradient, borderRadius: BorderRadius.circular(12)),
                      child: const Row(children: [Icon(Icons.call_rounded, color: Colors.white, size: 16), SizedBox(width: 6), Text('Call', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => widget.onToast('Email opened!'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
                      child: const Row(children: [Icon(Icons.mail_rounded, color: AppColors.onSurface, size: 16), SizedBox(width: 6), Text('Email', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700))]),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats
          Row(children: [
            _profileStat('3', 'Projects'),
            const SizedBox(width: 10),
            _profileStat('28', 'Tasks Done'),
            const SizedBox(width: 10),
            _profileStat('94%', 'Attend.'),
          ]),
          const SizedBox(height: 16),

          // Info
          CardContainer(
            child: Column(
              children: info.map((i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                      child: Icon(i['icon'] as IconData, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(i['label'] as String, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        Text(i['val'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                      ],
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Role Management
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Role & Permissions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.onSurface)),
                const SizedBox(height: 14),
                const Text('ASSIGNED ROLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: DropdownButton<String>(
                    value: 'Senior Architect',
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: ['Senior Architect', 'Junior Architect', 'Principal Architect', 'Admin / HR']
                        .map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                    onChanged: (_) {},
                  ),
                ),
                const SizedBox(height: 14),
                GoldGradientButton(
                  text: 'Update Role',
                  verticalPadding: 14,
                  onTap: () => widget.onToast('Role updated successfully!'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileStat(String val, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  void _showAddEmployeeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Add Employee', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _mField('First Name', 'Rahul')),
                const SizedBox(width: 12),
                Expanded(child: _mField('Last Name', 'Sharma')),
              ]),
              const SizedBox(height: 12),
              _mField('Work Email', 'rahul@ywarchitects.com'),
              const SizedBox(height: 12),
              _mDropdown('Role', ['Junior Architect', 'Senior Architect', 'Interior Designer', 'Site Engineer', '3D Visualizer', 'Admin / HR']),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _mField('Department', 'Architecture')),
                const SizedBox(width: 12),
                Expanded(child: _mField('Phone', '+91 98765 43210')),
              ]),
              const SizedBox(height: 20),
              GoldGradientButton(
                text: 'Add Employee',
                onTap: () { Navigator.pop(context); widget.onToast('Employee added successfully!'); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mField(String label, String hint) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
      const SizedBox(height: 6),
      TextField(decoration: InputDecoration(
        hintText: hint,
        filled: true, fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      )),
    ]);
  }

  Widget _mDropdown(String label, List<String> options) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: DropdownButton<String>(
          value: options.first,
          isExpanded: true,
          underline: const SizedBox(),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (_) {},
        ),
      ),
    ]);
  }
}
