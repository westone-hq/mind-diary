import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'presentation/layouts/main_layout.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MindDiaryApp(),
    ),
  );
}

class MindDiaryApp extends StatelessWidget {
  const MindDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Modify AppTheme to use Google Fonts Pretendard if available, 
    // or fallback to default sans-serif for now. 
    // We will apply it generally.
    final baseTheme = AppTheme.lightTheme;
    final textTheme = GoogleFonts.notoSansKrTextTheme(baseTheme.textTheme);

    return MaterialApp(
      title: '마음일기',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(textTheme: textTheme),
      home: const MainLayout(),
    );
  }
}
