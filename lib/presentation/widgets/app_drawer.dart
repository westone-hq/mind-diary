import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppColors.bgBase,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 40, 24, 16),
              child: Text('마음일기 사용자', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textMain)),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(LucideIcons.users, color: AppColors.textSub, size: 20),
              title: const Text('친구 관리', style: TextStyle(color: AppColors.textMain, fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                ref.read(currentScreenProvider.notifier).state = 'S7';
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.bell, color: AppColors.textSub, size: 20),
              title: const Text('알림', style: TextStyle(color: AppColors.textMain, fontSize: 16)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(LucideIcons.fileText, color: AppColors.textSub, size: 20),
              title: const Text('약관', style: TextStyle(color: AppColors.textMain, fontSize: 16)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(LucideIcons.shield, color: AppColors.textSub, size: 20),
              title: const Text('개인정보 처리방침', style: TextStyle(color: AppColors.textMain, fontSize: 16)),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(indent: 24, endIndent: 24),
            ListTile(
              leading: const Icon(LucideIcons.trash2, color: AppColors.bgUser, size: 20),
              title: const Text('모든 흔적 지우기', style: TextStyle(color: AppColors.bgUser, fontSize: 16)),
              onTap: () {
                // TODO: show erase dialog
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
