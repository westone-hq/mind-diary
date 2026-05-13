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

    // Hide Header for specific screens if needed
    final showHeader = currentScreen != 'S6' && currentScreen != 'S8';
    
    // Hide TabBar for conversational screens
    final hideTabBar = ['S2', 'S3', 'S4'].contains(currentScreen);

    return Scaffold(
      appBar: showHeader ? const GlobalHeader() : null,
      endDrawer: const AppDrawer(),
      body: _buildScreen(currentScreen),
      bottomNavigationBar: hideTabBar ? null : const GlobalTabBar(),
    );
  }

  Widget _buildScreen(String screenId) {
    switch (screenId) {
      case 'S1':
        return const S1Screen();
      case 'S2':
        return const S2Screen();
      case 'S3':
        return const S3Screen();
      case 'S4':
        return const S4Screen();
      case 'S5':
        return const S5Screen();
      case 'S6':
        return const S6Screen();
      case 'S7':
        return const S7Screen();
      case 'S8':
        return const S8Screen();
      default:
        return Center(child: Text('Unknown Screen: $screenId'));
    }
  }
}
