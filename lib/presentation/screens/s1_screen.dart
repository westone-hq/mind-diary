import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';

class S1Screen extends ConsumerStatefulWidget {
  const S1Screen({super.key});

  @override
  ConsumerState<S1Screen> createState() => _S1ScreenState();
}

class _S1ScreenState extends ConsumerState<S1Screen> {
  final TextEditingController _controller = TextEditingController();
  bool _hasInput = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasInput = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleAction() {
    final convoNotifier = ref.read(conversationProvider.notifier);
    if (!ref.read(conversationProvider).isActive) {
      convoNotifier.startConversation();
    }

    if (_hasInput) {
      // Handle text input, go to S3
      ref.read(currentScreenProvider.notifier).state = 'S3';
    } else {
      // Go to S2 (Voice)
      ref.read(currentScreenProvider.notifier).state = 'S2';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                '오늘 하루 어땠어?',
                style: TextStyle(
                  color: AppColors.textFaint,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.divider),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '메시지 입력',
                      hintStyle: TextStyle(color: AppColors.textFaint, fontSize: 16),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: AppColors.textMain, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _handleAction,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _hasInput ? LucideIcons.arrowUp : LucideIcons.mic,
                    color: AppColors.cardWhite,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
