import 'package:flutter/material.dart';

import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settings;
  const SettingsScreen({super.key, required this.settings});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const int _minSeconds = 3;
  static const int _maxSeconds = 120;

  late bool _useCustom;
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    final current = widget.settings.customTimeLimitSeconds;
    _useCustom = current != null;
    _sliderValue = (current ?? 15).clamp(_minSeconds, _maxSeconds).toDouble();
  }

  Future<void> _save() async {
    await widget.settings.setCustomTimeLimit(_useCustom ? _sliderValue.round() : null);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_useCustom ? 'Time limit set to ${_sliderValue.round()}s everywhere' : 'Using each quiz\'s default time limit'),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Question timer', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'By default each quiz uses its own time limit (5s for the quiz and '
                    'random practice; 20-45s per Logic Trainer category). Turn this on to '
                    'use one custom limit everywhere instead.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Use a custom time limit'),
                    value: _useCustom,
                    onChanged: (v) => setState(() => _useCustom = v),
                  ),
                  if (_useCustom) ...[
                    const SizedBox(height: 12),
                    Text(
                      '${_sliderValue.round()} seconds',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: _sliderValue,
                      min: _minSeconds.toDouble(),
                      max: _maxSeconds.toDouble(),
                      divisions: _maxSeconds - _minSeconds,
                      label: '${_sliderValue.round()}s',
                      onChanged: (v) => setState(() => _sliderValue = v),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _save,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
