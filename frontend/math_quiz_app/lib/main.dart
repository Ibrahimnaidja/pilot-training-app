import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/quiz_screen.dart';
import 'services/api_client.dart';
import 'services/settings_service.dart';

void main() {
  runApp(const MathQuizApp());
}

class MathQuizApp extends StatelessWidget {
  const MathQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Addition practice',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF3B5BA5),
        useMaterial3: true,
      ),
      home: const _StartupGate(),
    );
  }
}

/// Loads any saved session before deciding whether to show the login screen
/// or jump straight into the quiz.
class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  final ApiClient _api = ApiClient();
  final SettingsService _settings = SettingsService();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future.wait([_api.loadSession(), _settings.load()]).then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _api.isLoggedIn
        ? QuizScreen(api: _api, settings: _settings)
        : AuthScreen(api: _api, settings: _settings);
  }
}
