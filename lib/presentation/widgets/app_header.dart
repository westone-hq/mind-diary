import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import 'app_drawer.dart';

class GlobalHeader extends ConsumerWidget implements PreferredSizeWidget {
  const GlobalHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScreen = ref.watch(currentScreenProvider);
    final showBack = ['S2', 'S3', 'S4', 'S6', 'S8'].contains(currentScreen);

    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textMain),
              onPressed: () {
                if (currentScreen == 'S2' || currentScreen == 'S3') {
                  ref.read(conversationProvider.notifier).endConversation();
                  ref.read(currentScreenProvider.notifier).state = 'S4';
                } else if (currentScreen == 'S4') {
                  ref.read(conversationProvider.notifier).clearMessages();
                  ref.read(pendingDiaryProvider.notifier).state = null;
                  ref.read(directDiaryModeProvider.notifier).state = false;
                  ref.read(currentScreenProvider.notifier).state = 'S1';
                } else if (currentScreen == 'S6') {
                  ref.read(currentScreenProvider.notifier).state = 'S5';
                } else if (currentScreen == 'S8') {
                  ref.read(currentScreenProvider.notifier).state = 'S7';
                }
              },
            )
          : null,
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.sprout, color: AppColors.textMain),
          onPressed: () => _showCrisisSheet(context),
        ),
        IconButton(
          icon: const Icon(LucideIcons.menu, color: AppColors.textMain),
          onPressed: () => _showAppDrawer(context, ref),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  void _showAppDrawer(BuildContext context, WidgetRef ref) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, _, __) => Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.78,
            height: double.infinity,
            child: const AppDrawer(),
          ),
        ),
      ),
      transitionBuilder: (context, animation, _, child) {
        return SlideTransition(
          position: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)
              .drive(Tween(begin: const Offset(1, 0), end: Offset.zero)),
          child: child,
        );
      },
    );
  }

  void _showCrisisSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          padding: const EdgeInsets.only(bottom: 24, top: 12),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('지금 누군가와 이야기하고 싶다면', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textMain)),
                  ),
                ),
                const SizedBox(height: 16),
                _buildCrisisItem(context, LucideIcons.phone, '1393', '자살예방상담전화'),
                _buildCrisisItem(context, LucideIcons.phone, '1388', '청소년상담전화'),
                _buildCrisisItem(context, LucideIcons.phone, '1577-0199', '정신건강위기상담'),
                _buildCrisisItem(context, LucideIcons.messageSquare, '109', 'SOS 문자상담'),
                _buildCrisisItem(context, LucideIcons.mapPin, '가까운 쉼터', '청소년쉼터 찾기'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCrisisItem(BuildContext context, IconData icon, String title, String subtitle) {
    return InkWell(
      onTap: () {
        // TODO: launch tel:/sms: url
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('준비 중이야')));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              SizedBox(width: 40, child: Center(child: Icon(icon, color: AppColors.primary, size: 24))),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textMain)),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSub)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
