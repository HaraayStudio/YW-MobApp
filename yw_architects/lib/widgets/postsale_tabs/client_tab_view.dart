import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common_widgets.dart';

class ClientTabView extends StatelessWidget {
  final Map<String, dynamic> project;

  const ClientTabView({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final clientNode = project['client'] ?? {};
    
    final name = clientNode['name']?.toString() ?? 'Unknown Client';
    final email = clientNode['email']?.toString() ?? 'No Email';
    final phone = clientNode['phone']?.toString() ?? 'No Phone';
    final gstin = clientNode['gstNumber']?.toString() ?? clientNode['gstin']?.toString() ?? 'Not Provided';
    final address = clientNode['address']?.toString() ?? 'No Address';

    final init = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AvatarWidget(initials: init, size: 48, fontSize: 18),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                        Text(
                          'Client Profile',
                          style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: AppColors.outlineVariant),
              ),
              _buildInfoRow(Icons.email_outlined, 'Email', email),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.phone_outlined, 'Phone', phone),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.receipt_long_outlined, 'GSTIN', gstin),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.business_outlined, 'Billing Address', address),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
            ],
          ),
        ),
      ],
    );
  }
}

