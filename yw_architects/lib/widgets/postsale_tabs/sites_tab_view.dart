import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common_widgets.dart';

class SitesTabView extends StatelessWidget {
  final Map<String, dynamic> project;

  const SitesTabView({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.architecture_rounded, size: 48, color: AppColors.outlineVariant),
              const SizedBox(height: 16),
              const Text(
                'Execution Sites',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
              const SizedBox(height: 8),
              const Text(
                'Access structural designs, site progression, and specific task arrays inside the Site Execution Module.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {}, // Future navigation to full sites view
                icon: const Icon(Icons.dashboard_customize_rounded, size: 18),
                label: const Text('Open Sites Execution'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

