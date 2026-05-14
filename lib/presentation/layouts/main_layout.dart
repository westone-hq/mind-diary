import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../screens/screens.dart';
import '../widgets/common_widgets.dart';

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScreen = ref.watch(currentScreenProvider);

    final showHeader = currentScreen != 'S6' && currentScreen != 'S8';
    final hideTabBar = ['S2', 'S3', 'S4'].contains(currentScreen);

    return Scaffold(
      appBar: showHeader ? const GlobalHeader() : null,
      body: _buildScreen(currentScreen),
      bottomNavigationBar: hideTabBar ? null : const GlobalTabBar(),
    );
  }

  Widget _buildScreen(String screenId) {
    switch (screenId) {
      case 'S1':
        return const HomeScreen();
      case 'S2':
        return const VoiceChatScreen();
      case 'S3':
        return const TextChatScreen();
      case 'S4':
        return const DiaryPreviewScreen();
      case 'S5':
        return const DiaryListScreen();
      case 'S6':
        return const DiaryDetailScreen();
      case 'S7':
        return const TrustedPersonsScreen();
      case 'S8':
        return const TrustedPersonFormScreen();
      default:
        return Center(child: Text('Unknown Screen: $screenId'));
    }
  }
}
