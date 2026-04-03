import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../widgets/common_widgets.dart';

class TasksSection extends StatefulWidget {
  final AppUser user;
  final Function(String) onToast;

  const TasksSection({super.key, required this.user, required this.onToast});

  @override
  State<TasksSection> createState() => _TasksSectionState();
}

class _TasksSectionState extends State<TasksSection> {
  String _filter = 'All';

  final _tasks = [
    {'id': 1, 'title': 'Ground floor structural drawings — Sunrise Villa', 'project': 'Sunrise Villa', 'assignee': 'Rahul K.', 'priority': 'high', 'status': 'In Progress', 'due': 'Today', 'overdue': false},
    {'id': 2, 'title': 'Prepare 3D model for Metro Complex — Lobby', 'project': 'Metro Office', 'assignee': 'Varun R.', 'priority': 'medium', 'status': 'In Progress', 'due': 'Tomorrow', 'overdue': false},
    {'id': 3, 'title': 'Material schedule update — Green Residency bathrooms', 'project': 'Green Residency', 'assignee': 'Priya S.', 'priority': 'low', 'status': 'Pending', 'due': '28 Mar', 'overdue': false},
    {'id': 4, 'title': 'Site inspection checklist — Level 3 slab pour', 'project': 'Sunrise Villa', 'assignee': 'Amit J.', 'priority': 'high', 'status': 'Pending', 'due': '26 Mar', 'overdue': true},
    {'id': 5, 'title': 'Client presentation deck preparation', 'project': 'Harmony Heights', 'assignee': 'Kavya R.', 'priority': 'medium', 'status': 'Done', 'due': '20 Mar', 'overdue': false},
    {'id': 6, 'title': 'Electrical layout review — Metro basement', 'project': 'Metro Office', 'assignee': 'Rahul K.', 'priority': 'medium', 'status': 'Review', 'due': '30 Mar', 'overdue': false},
  ];

  bool get canCreate => [UserRole.admin, UserRole.coFounder, UserRole.hr, UserRole.srArchitect, UserRole.srEngineer, UserRole.liaisonManager].contains(widget.user.role);

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'All') return _tasks;
    return _tasks.where((t) => t['status'] == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['All', 'In Progress', 'Pending', 'Review', 'Done'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: SectionHeader(title: 'Tasks', subtitle: '${_tasks.length} tasks assigned')),
              if (canCreate)
                GestureDetector(
                  onTap: () => _showTaskModal(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(gradient: goldGradient, borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]),
                    child: const Row(children: [Icon(Icons.add_rounded, color: Colors.white, size: 16), SizedBox(width: 4), Text('New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))]),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 20),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final t = tabs[i];
                final active = _filter == t;
                return GestureDetector(
                  onTap: () => setState(() => _filter = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.outline)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ..._filtered.map((t) {
            final priority = t['priority'] as String;
            final status = t['status'] as String;
            final overdue = t['overdue'] as bool;
            final done = status == 'Done';
            Color leftColor = priority == 'high' ? AppColors.error : priority == 'medium' ? AppColors.chipProgressFg : AppColors.chipDoneFg;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border(left: BorderSide(color: leftColor, width: 3)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => widget.onToast('Task status updated!'),
                        child: Container(
                          width: 20, height: 20,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done ? AppColors.primary : Colors.transparent,
                            border: Border.all(color: done ? AppColors.primary : AppColors.outlineVariant, width: 2),
                          ),
                          child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 12) : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t['title'] as String,
                              style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface,
                                decoration: done ? TextDecoration.lineThrough : null,
                                decorationColor: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
                                  child: Text(t['project'] as String, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
                                ),
                                Text('→ ${t['assignee']}', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0x1A4D4636)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(spacing: 6, children: [
                        GoldChip(
                          text: priority.toUpperCase(),
                          bg: priority == 'high' ? AppColors.chipProgressBg : priority == 'medium' ? AppColors.chipPlanningBg : AppColors.chipDoneBg,
                          fg: priority == 'high' ? AppColors.chipProgressFg : priority == 'medium' ? AppColors.chipPlanningFg : AppColors.chipDoneFg,
                        ),
                        StatusChip(status: status),
                      ]),
                      Row(
                        children: [
                          Icon(overdue ? Icons.warning_rounded : Icons.schedule_rounded,
                              color: overdue ? AppColors.error : AppColors.onSurfaceVariant, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${overdue ? 'OVERDUE · ' : ''}Due ${t['due']}',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: overdue ? AppColors.error : AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showTaskModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TaskModal(onSubmit: () => widget.onToast('Task created successfully!')),
    );
  }
}

class _TaskModal extends StatelessWidget {
  final VoidCallback onSubmit;
  const _TaskModal({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('New Task', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
          ]),
          const SizedBox(height: 16),
          _modalField('Task Title', 'e.g. Prepare floor plan drawings'),
          const SizedBox(height: 12),
          _modalDropdown('Assign To', ['Rahul Sharma (Senior Architect)', 'Priya Singh (Interior Designer)', 'Amit Joshi (Site Engineer)', 'Kavya Rao (Junior Architect)']),
          const SizedBox(height: 12),
          _modalDropdown('Project', ['Sunrise Villa — Baner', 'Metro Office Complex', 'Green Residency']),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _modalField('Due Date', 'Select date')),
            const SizedBox(width: 12),
            Expanded(child: _modalDropdown('Priority', ['High', 'Medium', 'Low'])),
          ]),
          const SizedBox(height: 12),
          _modalField('Description', 'Task details...', maxLines: 3),
          const SizedBox(height: 20),
          GoldGradientButton(
            text: 'Create Task',
            onTap: () { Navigator.pop(context); onSubmit(); },
          ),
        ],
      ),
    );
  }

  Widget _modalField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
        const SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _modalDropdown(String label, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }
}
