import 'package:shared_preferences/shared_preferences.dart';

/// A single custom per-question time limit that, when set, overrides every
/// timed screen's own default (5s for the quiz/random practice, 20-45s per
/// Logic Trainer category) — shared app-wide so changing it in one place
/// applies everywhere.
class SettingsService {
  static const _timeLimitKey = 'custom_time_limit_seconds';

  int? _customTimeLimitSeconds;
  int? get customTimeLimitSeconds => _customTimeLimitSeconds;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _customTimeLimitSeconds = prefs.getInt(_timeLimitKey);
  }

  Future<void> setCustomTimeLimit(int? seconds) async {
    final prefs = await SharedPreferences.getInstance();
    if (seconds == null) {
      await prefs.remove(_timeLimitKey);
    } else {
      await prefs.setInt(_timeLimitKey, seconds);
    }
    _customTimeLimitSeconds = seconds;
  }

  int resolveTimeLimit(int defaultSeconds) => _customTimeLimitSeconds ?? defaultSeconds;
}
