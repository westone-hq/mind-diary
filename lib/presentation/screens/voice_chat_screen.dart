import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/message_list.dart';

class VoiceChatScreen extends ConsumerStatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  ConsumerState<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends ConsumerState<VoiceChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isPaused = false;
  bool _isWaitingAi = false;
  int _userMsgCount = 0;

  final List<String> _mockUserUtterances = [
    "오늘 좀 짜증났어",
    "그냥 별일 없었어",
    "친구랑 좀 다퉜는데",
  ];

  final List<String> _mockAiResponses = [
    "응, 듣고 있어. 천천히 말해도 돼.",
    "그랬구나. 그때 기분이 어땠어?",
    "음, 그 마음 알 것 같아.",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lastConversationModeProvider.notifier).state = ConversationMode.voice;
      if (!ref.read(conversationProvider).isActive) {
        ref.read(conversationProvider.notifier).startConversation();
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _addMockUtterance() {
    if (_isWaitingAi) return;

    final userText = _mockUserUtterances[_userMsgCount % _mockUserUtterances.length];
    final userMsg = Message(id: DateTime.now().millisecondsSinceEpoch, role: MessageRole.user, text: userText);

    ref.read(conversationProvider.notifier).addMessage(userMsg);

    setState(() {
      _userMsgCount++;
      _isWaitingAi = true;
    });

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final aiText = _mockAiResponses[(_userMsgCount - 1) % _mockAiResponses.length];
      final aiMsg = Message(id: DateTime.now().millisecondsSinceEpoch, role: MessageRole.ai, text: aiText);
      ref.read(conversationProvider.notifier).addMessage(aiMsg);

      setState(() => _isWaitingAi = false);
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    });
  }

  @override
  Widget build(BuildContext context) {
    final convoState = ref.watch(conversationProvider);

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _addMockUtterance,
            child: const Text(
              '[테스트] 사용자 발화 추가',
              style: TextStyle(fontSize: 12, color: AppColors.textFaint),
            ),
          ),
        ),
        Expanded(
          child: MessageList(
            messages: convoState.messages,
            isWaitingAi: _isWaitingAi,
            scrollController: _scrollController,
          ),
        ),
        SizedBox(
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _WaveIndicator(isWaitingAi: _isWaitingAi, isPaused: _isPaused),
              const SizedBox(height: 12),
              Text(
                _isWaitingAi ? "잠깐만" : "듣고 있어",
                style: const TextStyle(fontSize: 14, color: AppColors.textSub),
              ),
            ],
          ),
        ),
        Container(
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.bgBase,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(_isPaused ? LucideIcons.play : LucideIcons.pause),
                color: AppColors.textSub,
                onPressed: () => setState(() => _isPaused = !_isPaused),
              ),
              IconButton(
                icon: const Icon(LucideIcons.keyboard),
                color: AppColors.textSub,
                onPressed: () => ref.read(currentScreenProvider.notifier).state = 'S3',
              ),
              IconButton(
                icon: const Icon(LucideIcons.x),
                color: AppColors.bgUser,
                onPressed: () {
                  // TODO: show exit confirm sheet
                  ref.read(conversationProvider.notifier).endConversation();
                  ref.read(currentScreenProvider.notifier).state = 'S4';
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WaveIndicator extends StatefulWidget {
  final bool isWaitingAi;
  final bool isPaused;

  const _WaveIndicator({required this.isWaitingAi, required this.isPaused});

  @override
  State<_WaveIndicator> createState() => _WaveIndicatorState();
}

class _WaveIndicatorState extends State<_WaveIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    if (!widget.isPaused) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _WaveIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused && !oldWidget.isPaused) {
      _controller.stop();
    } else if (!widget.isPaused && oldWidget.isPaused) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final delays = [0.0, 0.15, 0.3, 0.15, 0.0];
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double value = _controller.value - delays[index];
            if (value < 0) value = 0;
            double height = 8 + 32 * (value < 0.5 ? value * 2 : (1 - value) * 2);
            if (widget.isPaused) height = 8;

            return Container(
              width: 4,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: widget.isWaitingAi ? AppColors.bgUser : AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
    );
  }
}
