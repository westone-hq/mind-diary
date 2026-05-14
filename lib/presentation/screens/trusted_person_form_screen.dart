import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_snack_bar.dart';

class TrustedPersonFormScreen extends ConsumerStatefulWidget {
  const TrustedPersonFormScreen({super.key});

  @override
  ConsumerState<TrustedPersonFormScreen> createState() => _TrustedPersonFormScreenState();
}

class _TrustedPersonFormScreenState extends ConsumerState<TrustedPersonFormScreen> {
  int _step = 1;
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  String _relation = '';
  String _pairingCode = '';

  Friend? _editingFriend;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = ref.read(selectedFriendIdProvider);
      if (id != null) {
        final f = ref.read(friendsProvider).where((x) => x.id == id).firstOrNull;
        if (f != null) {
          setState(() {
            _editingFriend = f;
            _nicknameController.text = f.nickname;
            _contactController.text = f.contact;
            _relation = f.relation;
          });
        }
      }
    });
  }

  bool get _isEditMode => _editingFriend != null;
  bool get _isFormValid =>
      _nicknameController.text.trim().isNotEmpty &&
      _relation.isNotEmpty &&
      _contactController.text.trim().isNotEmpty;

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textFaint),
      filled: true,
      fillColor: AppColors.cardWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.divider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.divider)),
    );
  }

  void _showRelationSheet() {
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
              const Text('관계 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textMain)),
              const SizedBox(height: 16),
              const Divider(height: 1),
              ...['가족', '친구', '선생님', '상담사', '기타'].map((r) => ListTile(
                    title: Text(r, style: const TextStyle(fontSize: 16, color: AppColors.textMain)),
                    onTap: () {
                      setState(() => _relation = r);
                      Navigator.pop(context);
                    },
                  )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _generatePairingCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    _pairingCode = String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  void _handlePrimaryAction() {
    if (_isEditMode) {
      final updated = _editingFriend!.copyWith(
        nickname: _nicknameController.text.trim(),
        relation: _relation,
        contact: _contactController.text.trim(),
      );
      ref.read(friendsProvider.notifier).updateFriend(updated);
      ref.read(selectedFriendIdProvider.notifier).state = null;
      AppSnackBar.show(context, '저장됐어');
      ref.read(currentScreenProvider.notifier).state = 'S7';
    } else {
      if (_pairingCode.isEmpty) _generatePairingCode();
      setState(() => _step = 2);
    }
  }

  void _handleFinalize() {
    final newFriend = Friend(
      id: DateTime.now().millisecondsSinceEpoch,
      nickname: _nicknameController.text.trim(),
      relation: _relation,
      contact: _contactController.text.trim(),
      status: FriendStatus.pending,
    );
    ref.read(friendsProvider.notifier).addFriend(newFriend);
    ref.read(selectedFriendIdProvider.notifier).state = null;
    ref.read(currentScreenProvider.notifier).state = 'S7';
  }

  void _navigateBack() {
    ref.read(selectedFriendIdProvider.notifier).state = null;
    ref.read(currentScreenProvider.notifier).state = 'S7';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_step == 2) {
          setState(() => _step = 1);
          return;
        }
        _navigateBack();
      },
      child: Column(
        children: [
          if (_step == 1)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        _isEditMode ? '친구 정보 수정' : '새 친구 추가',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textMain),
                      ),
                    ),
                    const Text('별명', style: TextStyle(fontSize: 14, color: AppColors.textSub)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nicknameController,
                      maxLength: 10,
                      decoration: _fieldDecoration('어떻게 부를까?').copyWith(counterText: ''),
                      onChanged: (v) => setState(() {}),
                    ),
                    const SizedBox(height: 20),
                    const Text('관계', style: TextStyle(fontSize: 14, color: AppColors.textSub)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showRelationSheet,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _relation.isEmpty ? '선택하기' : _relation,
                              style: TextStyle(fontSize: 16, color: _relation.isEmpty ? AppColors.textFaint : AppColors.textMain),
                            ),
                            const Icon(LucideIcons.chevronDown, color: AppColors.textFaint, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('연락처', style: TextStyle(fontSize: 14, color: AppColors.textSub)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _contactController,
                      keyboardType: TextInputType.phone,
                      decoration: _fieldDecoration('010-0000-0000'),
                      onChanged: (v) => setState(() {}),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('초대 코드가 만들어졌어', style: TextStyle(fontSize: 16, color: AppColors.textMain)),
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _pairingCode.split('').map((c) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(c, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500, color: AppColors.textMain)),
                      )).toList(),
                    ),
                    const SizedBox(height: 48),
                    const Text('상대가 같은 앱에서 이 코드를 입력하면 연결돼.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textSub, height: 1.6)),
                  ],
                ),
              ),
            ),
          Container(
            color: AppColors.bgBase,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _step == 1
                ? SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isFormValid ? _handlePrimaryAction : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.divider,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: Text(
                        _isEditMode ? '저장하기' : '초대 보내기',
                        style: TextStyle(color: _isFormValid ? AppColors.cardWhite : AppColors.textFaint, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('공유 시트가 열려')));
                          },
                          icon: const Icon(LucideIcons.share2, size: 20, color: AppColors.cardWhite),
                          label: const Text('공유하기', style: TextStyle(color: AppColors.cardWhite, fontSize: 16, fontWeight: FontWeight.w500)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _handleFinalize,
                        child: const Text('다음에 보내기', style: TextStyle(color: AppColors.textSub, fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
