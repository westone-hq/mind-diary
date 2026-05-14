import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';

class GlobalTabBar extends ConsumerWidget {
  const GlobalTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScreen = ref.watch(currentScreenProvider);

    final isMessageActive = ['S1', 'S2', 'S3', 'S4'].contains(currentScreen);
    final isBookActive = currentScreen == 'S5' || currentScreen == 'S6';
    final isUsersActive = currentScreen == 'S7' || currentScreen == 'S8';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgBase,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTab(context, ref, LucideIcons.messageCircle, isMessageActive, 'S1'),
              _buildTab(context, ref, LucideIcons.bookOpen, isBookActive, 'S5'),
              _buildTab(context, ref, LucideIcons.users, isUsersActive, 'S7'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, WidgetRef ref, IconData icon, bool isActive, String targetScreen) {
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(currentScreenProvider.notifier).state = targetScreen,
        child: Center(
          child: Icon(icon, color: isActive ? AppColors.primary : AppColors.textFaint, size: 24),
        ),
      ),
    );
  }
}
