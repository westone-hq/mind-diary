import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';

class TrustedPersonsScreen extends ConsumerWidget {
  const TrustedPersonsScreen({super.key});

  void _showFriendMenu(BuildContext context, WidgetRef ref, Friend friend) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('수정', style: TextStyle(color: AppColors.textMain, fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(selectedFriendIdProvider.notifier).state = friend.id;
                  ref.read(currentScreenProvider.notifier).state = 'S8';
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('삭제', style: TextStyle(color: AppColors.bgUser, fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(context, ref, friend);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Friend friend) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('${friend.nickname}을(를) 삭제할까?', style: const TextStyle(fontSize: 16)),
          content: const Text('연결이 끊어지고 받은 응원 메시지도 사라져.', style: TextStyle(fontSize: 14, color: AppColors.textSub)),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: AppColors.textSub)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(friendsProvider.notifier).deleteFriend(friend.id);
              },
              child: const Text('삭제', style: TextStyle(color: AppColors.bgUser)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friends = ref.watch(friendsProvider);

    if (friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('아직 등록한 사람이 없어', style: TextStyle(fontSize: 14, color: AppColors.textSub)),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                ref.read(selectedFriendIdProvider.notifier).state = null;
                ref.read(currentScreenProvider.notifier).state = 'S8';
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                minimumSize: const Size(160, 48),
              ),
              child: const Text('추가하기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(friend.nickname, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textMain)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(friend.relation, style: const TextStyle(fontSize: 14, color: AppColors.textSub)),
                                if (friend.status == FriendStatus.pending) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.divider,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text('초대 중', style: TextStyle(fontSize: 11, color: AppColors.textSub)),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.moreHorizontal, color: AppColors.textFaint),
                        onPressed: () => _showFriendMenu(context, ref, friend),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (friends.length < 3)
            OutlinedButton.icon(
              onPressed: () {
                ref.read(selectedFriendIdProvider.notifier).state = null;
                ref.read(currentScreenProvider.notifier).state = 'S8';
              },
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('추가하기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                minimumSize: const Size(double.infinity, 48),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text('최대 3명까지 등록할 수 있어', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textSub)),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
