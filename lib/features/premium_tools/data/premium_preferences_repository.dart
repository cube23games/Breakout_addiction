import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/local_data_safety.dart';
import '../domain/premium_preferences.dart';

class PremiumPreferencesRepository {
  static const String _routineFocusKey =
      'premium_preferences_routine_focus';
  static const String _reportDetailKey =
      'premium_preferences_report_detail';
  static const String _widgetFocusKey =
      'premium_preferences_widget_focus';

  Future<PremiumPreferences> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final defaults = PremiumPreferences.defaults();
    return PremiumPreferences(
      routineFocus: LocalDataSafety.enumByName(
        PremiumRoutineFocus.values,
        prefs.getString(_routineFocusKey),
        defaults.routineFocus,
      ),
      reportDetail: LocalDataSafety.enumByName(
        PremiumReportDetail.values,
        prefs.getString(_reportDetailKey),
        defaults.reportDetail,
      ),
      widgetFocus: LocalDataSafety.enumByName(
        PremiumWidgetFocus.values,
        prefs.getString(_widgetFocusKey),
        defaults.widgetFocus,
      ),
    );
  }

  Future<void> save(PremiumPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _routineFocusKey,
      preferences.routineFocus.name,
    );
    await prefs.setString(
      _reportDetailKey,
      preferences.reportDetail.name,
    );
    await prefs.setString(
      _widgetFocusKey,
      preferences.widgetFocus.name,
    );
  }
}
