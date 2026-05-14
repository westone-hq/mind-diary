class DateFormatter {
  static const _dayNames = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];

  static String toLabelFull(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.month}월 ${date.day}일 ${_dayNames[date.weekday % 7]}';
    } catch (_) {
      return dateStr;
    }
  }

  static String toLabelShort(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.month}월 ${date.day}일';
    } catch (_) {
      return dateStr;
    }
  }

  static String toIso(int year, int month, int day) {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}
