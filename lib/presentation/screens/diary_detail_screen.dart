import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../widgets/app_snack_bar.dart';

class DiaryDetailScreen extends ConsumerStatefulWidget {
  const DiaryDetailScreen({super.key});

  @override
  ConsumerState<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends ConsumerState<DiaryDetailScreen> {
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

  void _handleSave() {
    if (_textController.text.trim().isEmpty || _diary == null) return;

    final updated = _diary!.copyWith(text: _textController.text.trim());
    ref.read(diariesProvider.notifier).updateDiary(updated);

    setState(() {
      _diary = updated;
      _isEditing = false;
    });

    AppSnackBar.show(context, '수정됐어');
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_isEditing && _textController.text != _diary!.text) {
          setState(() {
            _isEditing = false;
            _textController.text = _diary!.text;
          });
          return;
        }
        ref.read(selectedDiaryIdProvider.notifier).state = null;
        ref.read(currentScreenProvider.notifier).state = 'S5';
      },
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
              child: Text(
                DateFormatter.toLabelFull(_diary!.date),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.textMain),
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
      ),
    );
  }
}
