class AiFairUsePolicy {
  const AiFairUsePolicy._();

  static const int dailyRequestLimit = 40;
  static const int maxInputCharacters = 1500;
  static const int recentMessageLimit = 8;

  static String periodKey(DateTime time) {
    final utc = time.toUtc();
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '${utc.year}-$month-$day';
  }
}
