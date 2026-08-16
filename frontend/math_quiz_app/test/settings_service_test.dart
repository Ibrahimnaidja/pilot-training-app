import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:math_quiz_app/services/settings_service.dart';

void main() {
  test('defaults to no override until a custom limit is set', () {
    final settings = SettingsService();
    expect(settings.customTimeLimitSeconds, isNull);
    expect(settings.resolveTimeLimit(20), 20);
  });

  test('setting a custom limit overrides every default, until cleared', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsService();

    await settings.setCustomTimeLimit(12);
    expect(settings.customTimeLimitSeconds, 12);
    expect(settings.resolveTimeLimit(5), 12);
    expect(settings.resolveTimeLimit(45), 12);

    await settings.setCustomTimeLimit(null);
    expect(settings.customTimeLimitSeconds, isNull);
    expect(settings.resolveTimeLimit(5), 5);
  });

  test('persists across instances via load()', () async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService().setCustomTimeLimit(30);

    final reloaded = SettingsService();
    expect(reloaded.customTimeLimitSeconds, isNull, reason: 'not loaded yet');
    await reloaded.load();
    expect(reloaded.customTimeLimitSeconds, 30);
  });
}
