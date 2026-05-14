import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../widgets/app_snack_bar.dart';

class DiaryPreviewScreen extends ConsumerStatefulWidget {
  const DiaryPreviewScreen({super.key});

  @override
  ConsumerState<DiaryPreviewScreen> createState() => _DiaryPreviewScreenState();
}

class _DiaryPreviewScreenState extends ConsumerState<DiaryPreviewScreen> {
  bool _isConverting = true;
  bool _isEditing = false;
  bool _isDirect = false;
  String _editStartText = '';
  final TextEditingController _textController = TextEditingController();

  final List<String> _mockDiaryTexts = [
    "오늘은 하루 종일 마음이 조금 무거웠다. 특별한 일이 있었던 건 아닌데, 그냥 그런 날이었다. 이런 날도 있는 거라고 스스로에게 말해본다.",
    "친구와 있었던 일을 다시 떠올려봤다. 그때는 잘 모르겠던 감정이 이제 조금 정리된다. 완벽하게 풀린 건 아니지만, 그래도 조금은 가벼워졌다.",
    "잠을 못 잔 하루였다. 머리가 복잡할 때마다 잠이 잘 안 온다. 내일은 좀 일찍 누워봐야겠다. 그래도 오늘 이렇게 풀어내고 나니 한결 낫다.",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isDirect = ref.read(directDiaryModeProvider);
      if (_isDirect) {
        _initDirectMode();
      } else {
        _generatePendingDiary();
      }
    });
  }

  void _initDirectMode() {
    final now = DateTime.now();
    final newDiary = DiaryEntry(
      id: now.millisecondsSinceEpoch,
      date: DateFormatter.toIso(now.year, now.month, now.day),
      mode: ConversationMode.write,
      text: '',
    );
    ref.read(pendingDiaryProvider.notifier).state = newDiary;
    _textController.text = '';
    setState(() {
      _isConverting = false;
      _isEditing = true;
    });
  }

  void _generatePendingDiary() {
    final convoState = ref.read(conversationProvider);
    final convoLength = convoState.messages.length;
    final mockText = convoLength == 0
        ? _mockDiaryTexts[0]
        : _mockDiaryTexts[convoLength % _mockDiaryTexts.length];

    final now = DateTime.now();
    final newDiary = DiaryEntry(
      id: now.millisecondsSinceEpoch,
      date: DateFormatter.toIso(now.year, now.month, now.day),
      mode: ref.read(lastConversationModeProvider),
      text: mockText,
    );

    ref.read(pendingDiaryProvider.notifier).state = newDiary;
    _textController.text = mockText;
    ref.read(conversationProvider.notifier).endConversation();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _isConverting = false);
    });
  }

  void _handleSave() {
    final pendingDiary = ref.read(pendingDiaryProvider);
    if (pendingDiary == null) return;
    if (_textController.text.trim().isEmpty) return;

    final updatedDiary = pendingDiary.copyWith(text: _textController.text.trim());
    ref.read(diariesProvider.notifier).addDiary(updatedDiary);
    ref.read(conversationProvider.notifier).clearMessages();
    ref.read(pendingDiaryProvider.notifier).state = null;
    ref.read(directDiaryModeProvider.notifier).state = false;

    AppSnackBar.show(context, '저장됐어');
    ref.read(currentScreenProvider.notifier).state = 'S1';
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('이 일기를 삭제할까?', style: TextStyle(fontSize: 16)),
          content: const Text('지금 변환된 내용이 사라져. 대화는 다시 시작할 수 있어.', style: TextStyle(fontSize: 14, color: AppColors.textSub)),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: AppColors.textSub)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(conversationProvider.notifier).clearMessages();
                ref.read(pendingDiaryProvider.notifier).state = null;
                ref.read(directDiaryModeProvider.notifier).state = false;
                ref.read(currentScreenProvider.notifier).state = 'S1';
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
    final pendingDiary = ref.watch(pendingDiaryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            DateFormatter.toLabelFull(pendingDiary?.date ?? ''),
            style: const TextStyle(fontSize: 14, color: AppColors.textSub),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(18),
              ),
              child: _isConverting
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSkeletonLine(double.infinity),
                        const SizedBox(height: 12),
                        _buildSkeletonLine(MediaQuery.of(context).size.width * 0.7),
                        const SizedBox(height: 12),
                        _buildSkeletonLine(MediaQuery.of(context).size.width * 0.8),
                      ],
                    )
                  : _isEditing
                      ? TextField(
                          controller: _textController,
                          maxLines: null,
                          autofocus: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: _isDirect ? '오늘 하루를 적어봐' : null,
                            hintStyle: const TextStyle(color: AppColors.textFaint, fontSize: 16, height: 1.7),
                          ),
                          style: const TextStyle(fontSize: 16, height: 1.7, color: AppColors.textMain),
                        )
                      : Text(
                          _textController.text,
                          style: const TextStyle(fontSize: 16, height: 1.7, color: AppColors.textMain),
                        ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isConverting ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.divider,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: const Text('저장하기', style: TextStyle(color: AppColors.cardWhite, fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 16),
              if (!_isEditing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _isConverting
                          ? null
                          : () => setState(() {
                                _isEditing = true;
                                _editStartText = _textController.text;
                              }),
                      child: Text('수정', style: TextStyle(color: _isConverting ? AppColors.textFaint : AppColors.textSub)),
                    ),
                    const SizedBox(width: 32),
                    TextButton(
                      onPressed: _isConverting ? null : _showDeleteDialog,
                      child: Text('삭제', style: TextStyle(color: _isConverting ? AppColors.textFaint : AppColors.textSub)),
                    ),
                  ],
                )
              else if (_isDirect)
                TextButton(
                  onPressed: () {
                    ref.read(directDiaryModeProvider.notifier).state = false;
                    ref.read(pendingDiaryProvider.notifier).state = null;
                    ref.read(currentScreenProvider.notifier).state = 'S1';
                  },
                  child: const Text('취소', style: TextStyle(color: AppColors.textSub)),
                )
              else
                TextButton(
                  onPressed: () => setState(() {
                    _isEditing = false;
                    _textController.text = _editStartText;
                  }),
                  child: const Text('되돌리기', style: TextStyle(color: AppColors.textSub)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonLine(double width) {
    return Container(
      height: 14,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
