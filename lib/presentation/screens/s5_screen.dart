import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';

class S5Screen extends ConsumerStatefulWidget {
  const S5Screen({super.key});

  @override
  ConsumerState<S5Screen> createState() => _S5ScreenState();
}

class _S5ScreenState extends ConsumerState<S5Screen> {
  DateTime _viewMonth = DateTime.now();

  void _handlePrevMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1, 1);
    });
  }

  void _handleNextMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 1);
    });
  }

  String _formatDate(int year, int month, int day) {
    return "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final diaries = ref.watch(diariesProvider);
    final diaryMap = {for (var d in diaries) d.date: d.id};
    
    final today = DateTime.now();
    final todayStr = _formatDate(today.year, today.month, today.day);

    int daysInMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
    int startDayOfWeek = DateTime(_viewMonth.year, _viewMonth.month, 1).weekday;
    if (startDayOfWeek == 7) startDayOfWeek = 0; // Make Sunday 0

    // Calendar Days
    List<Map<String, dynamic>> calendarDays = [];
    
    // Prev month padding
    int prevMonthDays = DateTime(_viewMonth.year, _viewMonth.month, 0).day;
    for (int i = startDayOfWeek - 1; i >= 0; i--) {
      calendarDays.add({'day': prevMonthDays - i, 'isCurrent': false});
    }
    // Current month days
    for (int i = 1; i <= daysInMonth; i++) {
      calendarDays.add({'day': i, 'isCurrent': true});
    }
    // Next month padding to make 42 cells
    int remaining = 42 - calendarDays.length;
    for (int i = 1; i <= remaining; i++) {
      calendarDays.add({'day': i, 'isCurrent': false});
    }

    return Column(
      children: [
        // Month Navigation
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textSub), onPressed: _handlePrevMonth),
              Text('${_viewMonth.year}년 ${_viewMonth.month}월', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              IconButton(icon: const Icon(LucideIcons.chevronRight, color: AppColors.textSub), onPressed: _handleNextMonth),
            ],
          ),
        ),
        
        // Weekdays Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['일', '월', '화', '수', '목', '금', '토'].asMap().entries.map((entry) {
              int idx = entry.key;
              String day = entry.value;
              Color color = AppColors.textFaint;
              if (idx == 0) color = AppColors.bgUser;
              if (idx == 6) color = AppColors.primary;
              return Expanded(
                child: Center(
                  child: Text(day, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
                ),
              );
            }).toList(),
          ),
        ),
        
        // Calendar Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemBuilder: (context, index) {
              final cell = calendarDays[index];
              final isCurrent = cell['isCurrent'] as bool;
              final day = cell['day'] as int;
              
              String dateStr = "";
              if (isCurrent) {
                dateStr = _formatDate(_viewMonth.year, _viewMonth.month, day);
              }
              final bool hasDiary = isCurrent && diaryMap.containsKey(dateStr);
              final bool isToday = isCurrent && dateStr == todayStr;

              return InkWell(
                onTap: hasDiary ? () {
                  ref.read(selectedDiaryIdProvider.notifier).state = diaryMap[dateStr];
                  ref.read(currentScreenProvider.notifier).state = 'S6';
                } : null,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isToday)
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(color: AppColors.bgAi.withOpacity(0.5), shape: BoxShape.circle),
                      ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 14,
                            color: isCurrent ? AppColors.textMain : AppColors.textFaint,
                            fontWeight: isCurrent ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                        SizedBox(
                          height: 14,
                          child: hasDiary ? const Icon(LucideIcons.sprout, size: 10, color: AppColors.primary) : null,
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        
        const Divider(indent: 16, endIndent: 16, height: 32),
        
        // List of Diaries
        Expanded(
          child: diaries.isEmpty
              ? const Center(child: Text('아직 일기가 없어', style: TextStyle(color: AppColors.textSub, fontSize: 14)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: diaries.length,
                  itemBuilder: (context, index) {
                    final d = diaries[index];
                    final date = DateTime.parse(d.date);
                    final dateText = "${date.month}월 ${date.day}일";
                    final preview = d.text.length > 50 ? "${d.text.substring(0, 50)}..." : d.text;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          ref.read(selectedDiaryIdProvider.notifier).state = d.id;
                          ref.read(currentScreenProvider.notifier).state = 'S6';
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dateText, style: const TextStyle(fontSize: 14, color: AppColors.textSub)),
                              const SizedBox(height: 4),
                              Text(preview, style: const TextStyle(fontSize: 14, color: AppColors.textMain, height: 1.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
