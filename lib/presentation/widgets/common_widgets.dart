import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';

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
                if (currentScreen == 'S2' || currentScreen == 'S3' || currentScreen == 'S4') {
                  // TODO: showExitSheet 
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
          onPressed: () {
            _showCrisisSheet(context);
          },
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(LucideIcons.menu, color: AppColors.textMain),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

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
        // TODO: Action like launching url (tel:, sms:)
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
              )
            ],
          ),
        ),
      ),
    );
  }
}

class GlobalTabBar extends ConsumerWidget {
  const GlobalTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScreen = ref.watch(currentScreenProvider);
    
    // S1, S2, S3, S4 belong to Message tab
    bool isMessageActive = ['S1', 'S2', 'S3', 'S4'].contains(currentScreen);
    bool isBookActive = currentScreen == 'S5' || currentScreen == 'S6';
    bool isUsersActive = currentScreen == 'S7' || currentScreen == 'S8';

    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.bgBase,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTab(context, ref, LucideIcons.messageCircle, isMessageActive, 'S1'),
            _buildTab(context, ref, LucideIcons.bookOpen, isBookActive, 'S5'),
            _buildTab(context, ref, LucideIcons.users, isUsersActive, 'S7'),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, WidgetRef ref, IconData icon, bool isActive, String targetScreen) {
    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(currentScreenProvider.notifier).state = targetScreen;
        },
        child: Center(
          child: Icon(
            icon,
            color: isActive ? AppColors.primary : AppColors.textFaint,
            size: 24,
          ),
        ),
      ),
    );
  }
}

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
