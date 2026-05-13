import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';

class S6Screen extends ConsumerStatefulWidget {
  const S6Screen({super.key});

  @override
  ConsumerState<S6Screen> createState() => _S6ScreenState();
}

class _S6ScreenState extends ConsumerState<S6Screen> {
  bool _isEditing = false;
  final TextEditingController _textController = TextEditingController();
  DiaryEntry? _diary;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDiary();
    });
  }

  void _loadDiary() {
    final id = ref.read(selectedDiaryIdProvider);
    final diaries = ref.read(diariesProvider);
    final d = diaries.where((x) => x.id == id).firstOrNull;
    if (d != null) {
      setState(() {
        _diary = d;
        _textController.text = d.text;
      });
    }
  }

  String _formatDateString(String dateStr) {
    if (dateStr.isEmpty) return "";
    try {
      final date = DateTime.parse(dateStr);
      final dayNames = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"];
      final dayName = dayNames[date.weekday % 7];
      return "${date.month}월 ${date.day}일 $dayName";
    } catch (e) {
      return dateStr;
    }
  }

  IconData _getModeIcon(ConversationMode mode) {
    switch (mode) {
      case ConversationMode.voice: return LucideIcons.mic;
      case ConversationMode.text: return LucideIcons.messageCircle;
      case ConversationMode.write: return LucideIcons.edit;
    }
  }

  void _handleSave() {
    if (_textController.text.trim().isEmpty || _diary == null) return;
    
    final updated = _diary!.copyWith(text: _textController.text.trim());
    ref.read(diariesProvider.notifier).updateDiary(updated);
    
    setState(() {
      _diary = updated;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('수정됐어', textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: const EdgeInsets.only(bottom: 64, left: 100, right: 100),
        backgroundColor: AppColors.textMain,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('이 일기를 삭제할까?', style: TextStyle(fontSize: 16)),
          content: const Text('삭제하면 되돌릴 수 없어.', style: TextStyle(fontSize: 14, color: AppColors.textSub)),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: AppColors.textSub)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(diariesProvider.notifier).deleteDiary(_diary!.id);
                ref.read(selectedDiaryIdProvider.notifier).state = null;
                ref.read(currentScreenProvider.notifier).state = 'S5';
              },
              child: const Text('삭제', style: TextStyle(color: AppColors.bgUser)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_diary == null) {
      return const Center(child: Text('일기를 찾을 수 없어', style: TextStyle(color: AppColors.textSub)));
    }

    return WillPopScope(
      onWillPop: () async {
        if (_isEditing && _textController.text != _diary!.text) {
          // TODO: Show cancel dialog
          setState(() {
            _isEditing = false;
            _textController.text = _diary!.text;
          });
          return false;
        }
        ref.read(selectedDiaryIdProvider.notifier).state = null;
        ref.read(currentScreenProvider.notifier).state = 'S5';
        return false;
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              children: [
                Text(
                  _formatDateString(_diary!.date),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.textMain),
                ),
                const SizedBox(height: 8),
                Icon(_getModeIcon(_diary!.mode), size: 14, color: AppColors.textFaint),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _isEditing
                  ? TextField(
                      controller: _textController,
                      maxLines: null,
                      decoration: const InputDecoration(border: InputBorder.none),
                      style: const TextStyle(fontSize: 16, height: 1.7, color: AppColors.textMain),
                    )
                  : SingleChildScrollView(
                      child: Text(
                        _diary!.text,
                        style: const TextStyle(fontSize: 16, height: 1.7, color: AppColors.textMain),
                      ),
                    ),
            ),
          ),
          Container(
            color: AppColors.bgBase,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _isEditing
                ? SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: const Text('저장하기', style: TextStyle(color: AppColors.cardWhite, fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                  )
                : Column(
                    children: [
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => setState(() => _isEditing = true),
                            child: const Text('수정', style: TextStyle(color: AppColors.textSub, fontSize: 14)),
                          ),
                          const SizedBox(width: 32),
                          TextButton(
                            onPressed: _showDeleteDialog,
                            child: const Text('삭제', style: TextStyle(color: AppColors.textFaint, fontSize: 14)),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
