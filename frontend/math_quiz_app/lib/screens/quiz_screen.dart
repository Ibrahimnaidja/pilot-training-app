import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/settings_service.dart';
import 'auth_screen.dart';
import 'create_problem_screen.dart';
import 'leaderboard_screen.dart';
import 'logic_trainer_screen.dart';
import 'random_practice_screen.dart';
import 'settings_screen.dart';

class QuizScreen extends StatefulWidget {
  final ApiClient api;
  final SettingsService settings;
  const QuizScreen({super.key, required this.api, required this.settings});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();

  static const int _defaultTimeLimitSeconds = 5;
  int get _timeLimitSeconds => widget.settings.resolveTimeLimit(_defaultTimeLimitSeconds);
  Timer? _countdownTimer;
  int _secondsLeft = 0;

  Problem? _problem;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _totalCorrect = 0;
  int _totalAttempts = 0;

  bool _loading = true;
  bool _awaitingNext = false;
  String? _errorText;
  String? _feedbackText;
  Color _feedbackColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadNewProblem();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await widget.api.fetchStats();
      if (!mounted) return;
      setState(() {
        _currentStreak = stats.currentStreak;
        _bestStreak = stats.bestStreak;
        _totalCorrect = stats.totalCorrect;
        _totalAttempts = stats.totalAttempts;
      });
    } catch (_) {
      // Non-fatal — the problem card will surface connection errors instead.
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _secondsLeft = _timeLimitSeconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        _handleTimeout();
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  Future<void> _loadNewProblem() async {
    _countdownTimer?.cancel();
    setState(() {
      _loading = true;
      _errorText = null;
      _feedbackText = null;
      _answerController.clear();
      _awaitingNext = false;
    });

    try {
      final problem = await widget.api.fetchRandomProblem();
      if (!mounted) return;
      setState(() {
        _problem = problem;
        _loading = false;
      });
      _answerFocusNode.requestFocus();
      _startCountdown();
    } on ApiException catch (e) {
      setState(() {
        _loading = false;
        _errorText = e.message;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorText = "Couldn't reach the server. Check it's running, then try again.";
      });
    }
  }

  void _applyResult(Map<String, dynamic> result, {required String message, required Color color}) {
    setState(() {
      _totalAttempts = result['totalAttempts'] as int;
      _totalCorrect = result['totalCorrect'] as int;
      _currentStreak = result['currentStreak'] as int;
      _bestStreak = result['bestStreak'] as int;
      _feedbackColor = color;
      _feedbackText = message;
      _awaitingNext = true;
    });
  }

  Future<void> _handleTimeout() async {
    if (_awaitingNext || _problem == null) return;
    try {
      final result = await widget.api.submitAttempt(problemId: _problem!.id, timedOut: true);
      _applyResult(
        result,
        message: "Time's up. ${_problem!.displayExpression} = ${result['correctAnswer']}",
        color: Colors.red.shade700,
      );
    } catch (_) {
      setState(() {
        _feedbackColor = Colors.red.shade700;
        _feedbackText = "Time's up.";
        _awaitingNext = true;
      });
    }
  }

  Future<void> _submitAnswer() async {
    if (_awaitingNext) {
      _loadNewProblem();
      return;
    }
    if (_problem == null) return;

    final rawValue = _answerController.text.trim();
    if (rawValue.isEmpty) {
      setState(() => _errorText = 'Enter an answer first');
      return;
    }
    final answer = int.tryParse(rawValue);
    if (answer == null) {
      setState(() => _errorText = 'Enter a whole number');
      return;
    }
    setState(() => _errorText = null);
    _countdownTimer?.cancel();

    try {
      final result = await widget.api.submitAttempt(problemId: _problem!.id, answer: answer);
      final correct = result['correct'] as bool;
      _applyResult(
        result,
        message: correct
            ? 'Correct — ${_problem!.displayExpression} = ${result['correctAnswer']}'
            : 'Not quite. ${_problem!.displayExpression} = ${result['correctAnswer']}',
        color: correct ? Colors.green.shade700 : Colors.red.shade700,
      );
    } catch (e) {
      setState(() => _errorText = "Couldn't reach the server. Check it's running, then try again.");
    }
  }

  Future<void> _logOut() async {
    await widget.api.logOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => AuthScreen(api: widget.api, settings: widget.settings)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Addition practice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology_outlined),
            tooltip: 'Logic trainer',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => LogicTrainerScreen(api: widget.api, settings: widget.settings)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Random practice',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => RandomPracticeScreen(settings: widget.settings)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard_outlined),
            tooltip: 'Leaderboard',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => LeaderboardScreen(api: widget.api)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Create a problem',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CreateProblemScreen(api: widget.api)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SettingsScreen(settings: widget.settings)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: _logOut,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Signed in as ${widget.api.username ?? ''}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatBlock(label: 'score', value: '$_totalCorrect / $_totalAttempts'),
                      _StatBlock(label: 'streak', value: '$_currentStreak'),
                      _StatBlock(label: 'best', value: '$_bestStreak'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        if (_loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: CircularProgressIndicator(),
                          )
                        else if (_problem != null) ...[
                          Text(
                            '${_problem!.displayExpression} = ?',
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'from ${_problem!.createdByUsername}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 10),
                          if (!_awaitingNext)
                            Text(
                              '$_secondsLeft s left',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _secondsLeft <= 2 ? Colors.red.shade700 : Colors.grey.shade600,
                              ),
                            ),
                        ] else if (_errorText != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              children: [
                                Text(
                                  _errorText!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(onPressed: _loadNewProblem, child: const Text('Try again')),
                              ],
                            ),
                          ),
                        if (_problem != null) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _answerController,
                                  focusNode: _answerFocusNode,
                                  enabled: !_loading && !_awaitingNext,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    hintText: 'Your answer',
                                    border: OutlineInputBorder(),
                                  ),
                                  onSubmitted: (_) => _submitAnswer(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              FilledButton(
                                onPressed: _loading ? null : _submitAnswer,
                                child: Text(_awaitingNext ? 'Next' : 'Check'),
                              ),
                            ],
                          ),
                          if (_errorText != null) ...[
                            const SizedBox(height: 8),
                            Text(_errorText!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
                          ],
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_feedbackText != null)
                    Text(
                      _feedbackText!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _feedbackColor, fontWeight: FontWeight.w600),
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

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;

  const _StatBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
