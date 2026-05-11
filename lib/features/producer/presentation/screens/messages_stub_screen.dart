import 'package:flutter/material.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';

class MessagesStubScreen extends StatelessWidget {
  const MessagesStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.gray300),
            SizedBox(height: 16),
            Text(
              'Messagerie bientôt disponible',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Cette fonctionnalité est en cours de développement.',
              style: TextStyle(fontSize: 13, color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
