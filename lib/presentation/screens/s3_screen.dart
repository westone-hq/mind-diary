import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/message_list.dart';

class S3Screen extends ConsumerStatefulWidget {
  const S3Screen({super.key});

  @override
  ConsumerState<S3Screen> createState() => _S3ScreenState();
}

class _S3ScreenState extends ConsumerState<S3Screen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  bool _isWaitingAi = false;
  
  final List<String> _mockAiResponses = [
    "응, 듣고 있어. 천천히 말해도 돼.",
    "그랬구나. 그때 기분이 어땠어?",
    "음, 그 마음 알 것 같아.",
    "오늘 그런 일이 있었구나.",
    "더 얘기해줄래?"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lastConversationModeProvider.notifier).state = ConversationMode.text;
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

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty || _isWaitingAi) return;

    final userMsg = Message(id: DateTime.now().millisecondsSinceEpoch, role: MessageRole.user, text: text);
    ref.read(conversationProvider.notifier).addMessage(userMsg);
    
    _textController.clear();
    setState(() {
      _isWaitingAi = true;
    });
    
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final userCount = ref.read(conversationProvider).messages.where((m) => m.role == MessageRole.user).length;
      final aiText = _mockAiResponses[(userCount - 1) % _mockAiResponses.length];
      final aiMsg = Message(id: DateTime.now().millisecondsSinceEpoch, role: MessageRole.ai, text: aiText);
      
      ref.read(conversationProvider.notifier).addMessage(aiMsg);
      setState(() {
        _isWaitingAi = false;
      });
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    });
  }

  @override
  Widget build(BuildContext context) {
    final convoState = ref.watch(conversationProvider);

    return Column(
      children: [
        Expanded(
          child: MessageList(
            messages: convoState.messages,
            isWaitingAi: _isWaitingAi,
            scrollController: _scrollController,
          ),
        ),
        Container(
          color: AppColors.bgBase,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.divider),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: '메시지 입력',
                        hintStyle: TextStyle(color: AppColors.textFaint, fontSize: 16),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: AppColors.textMain, fontSize: 16),
                      onChanged: (v) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _textController.text.trim().isNotEmpty ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _textController.text.trim().isNotEmpty ? LucideIcons.arrowUp : LucideIcons.mic,
                      color: _textController.text.trim().isNotEmpty ? AppColors.cardWhite : AppColors.textSub,
                    ),
                    onPressed: () {
                      if (_textController.text.trim().isNotEmpty) {
                        _handleSend();
                      } else {
                        ref.read(currentScreenProvider.notifier).state = 'S2';
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
