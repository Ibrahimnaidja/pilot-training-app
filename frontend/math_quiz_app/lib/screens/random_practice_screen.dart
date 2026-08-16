import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/practice_problem.dart';
import '../services/settings_service.dart';

enum _Phase { setup, playing, summary }

/// Solo drill: numbers and operator (add/subtract) are generated on-device,
/// so unlike QuizScreen this never touches the backend and doesn't affect
/// the shared leaderboard. Runs as a fixed-length sequence chosen up front;
/// answering (Enter, a timeout, or the Check button) silently moves to the
/// next question with no correct/incorrect reveal — that only shows up in
/// the summary at the end, along with which questions were missed.
class RandomPracticeScreen extends StatefulWidget {
  final SettingsService settings;
  const RandomPracticeScreen({super.key, required this.settings});

  @override
  State<RandomPracticeScreen> createState() => _RandomPracticeScreenState();
}

class _RandomPracticeScreenState extends State<RandomPracticeScreen> {
  static const int _defaultTimeLimitSeconds = 5;
  int get _timeLimitSeconds => widget.settings.resolveTimeLimit(_defaultTimeLimitSeconds);
  static const List<int> _lengthPresets = [5, 10, 20, 50];

  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _customLengthController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();
  final Random _random = Random();

  _Phase _phase = _Phase.setup;
  int _sequenceLength = 10;
  bool _useCustomLength = false;
  String? _setupError;

  int _questionIndex = 0;
  late PracticeProblem _problem;
  DateTime? _questionStartedAt;
  final List<AnsweredQuestion> _answers = [];

  Timer? _countdownTimer;
  int _secondsLeft = 0;

  String? _errorText;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _answerController.dispose();
    _customLengthController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  PracticeProblem _generateProblem() {
    final operator = _random.nextBool() ? PracticeOperator.add : PracticeOperator.subtract;
    var num1 = 1 + _random.nextInt(99);
    var num2 = 1 + _random.nextInt(99);
    if (operator == PracticeOperator.subtract && num2 > num1) {
      final swap = num1;
      num1 = num2;
      num2 = swap;
    }
    return PracticeProblem(num1: num1, num2: num2, operator: operator);
  }

  void _start(int length) {
    setState(() {
      _sequenceLength = length;
      _phase = _Phase.playing;
      _questionIndex = 0;
      _answers.clear();
      _errorText = null;
      _problem = _generateProblem();
      _questionStartedAt = DateTime.now();
      _answerController.clear();
    });
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) => _answerFocusNode.requestFocus());
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

  void _handleTimeout() => _recordAnswer(givenAnswer: null, timedOut: true);

  void _submitAnswer() {
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
    _countdownTimer?.cancel();
    _recordAnswer(givenAnswer: answer, timedOut: false);
  }

  void _recordAnswer({required int? givenAnswer, required bool timedOut}) {
    final elapsed = DateTime.now().difference(_questionStartedAt!);
    final responseTime = timedOut ? Duration(seconds: _timeLimitSeconds) : elapsed;
    final correct = !timedOut && givenAnswer == _problem.correctAnswer;

    final answered = AnsweredQuestion(
      problem: _problem,
      givenAnswer: givenAnswer,
      correct: correct,
      timedOut: timedOut,
      responseTime: responseTime,
    );

    final isLast = _questionIndex + 1 >= _sequenceLength;

    setState(() {
      _errorText = null;
      _answers.add(answered);
      if (isLast) {
        _phase = _Phase.summary;
        return;
      }
      _questionIndex += 1;
      _problem = _generateProblem();
      _questionStartedAt = DateTime.now();
      _answerController.clear();
    });

    if (!isLast) {
      _startCountdown();
      WidgetsBinding.instance.addPostFrameCallback((_) => _answerFocusNode.requestFocus());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Random practice')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: switch (_phase) {
                _Phase.setup => _buildSetup(context),
                _Phase.playing => _buildPlaying(context),
                _Phase.summary => _buildSummary(context),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetup(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Random practice',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Addition and subtraction with random numbers, generated on-device. '
          "This run isn't saved to your account.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 28),
        Text('How many questions?', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final length in _lengthPresets)
              ChoiceChip(
                label: Text('$length'),
                selected: !_useCustomLength && _sequenceLength == length,
                onSelected: (_) => setState(() {
                  _useCustomLength = false;
                  _sequenceLength = length;
                  _setupError = null;
                }),
              ),
            ChoiceChip(
              label: const Text('Custom'),
              selected: _useCustomLength,
              onSelected: (_) => setState(() {
                _useCustomLength = true;
                _setupError = null;
              }),
            ),
          ],
        ),
        if (_useCustomLength) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _customLengthController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Number of questions', border: OutlineInputBorder()),
          ),
        ],
        if (_setupError != null) ...[
          const SizedBox(height: 8),
          Text(_setupError!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () {
            if (_useCustomLength) {
              final custom = int.tryParse(_customLengthController.text.trim());
              if (custom == null || custom < 1) {
                setState(() => _setupError = 'Enter a whole number of at least 1');
                return;
              }
              _start(custom);
            } else {
              _start(_sequenceLength);
            }
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Start'),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaying(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Question ${_questionIndex + 1} of $_sequenceLength',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: _questionIndex / _sequenceLength, minHeight: 6),
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
              Text(
                '${_problem.displayExpression} = ?',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                '$_secondsLeft s left',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _secondsLeft <= 2 ? Colors.red.shade700 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _answerController,
                      focusNode: _answerFocusNode,
                      autofocus: true,
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
                    onPressed: _submitAnswer,
                    child: const Text('Check'),
                  ),
                ],
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(_errorText!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(BuildContext context) {
    final total = _answers.length;
    final correct = _answers.where((a) => a.correct).length;
    final percentage = total == 0 ? 0.0 : correct / total * 100;
    final avgResponseSeconds = total == 0
        ? 0.0
        : _answers.fold<int>(0, (sum, a) => sum + a.responseTime.inMilliseconds) / total / 1000;
    final wrong = _answers.where((a) => !a.correct).toList();

    return ListView(
      shrinkWrap: true,
      children: [
        Text(
          'Sequence complete',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatBlock(label: 'score', value: '$correct / $total'),
            _StatBlock(label: 'accuracy', value: '${percentage.toStringAsFixed(0)}%'),
            _StatBlock(label: 'avg time', value: '${avgResponseSeconds.toStringAsFixed(1)}s'),
          ],
        ),
        const SizedBox(height: 28),
        if (wrong.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
            child: Text(
              'Perfect score — every answer was correct.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w600),
            ),
          )
        else ...[
          Text('Questions you missed (${wrong.length})', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...wrong.map((a) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('${a.problem.displayExpression} = ${a.problem.correctAnswer}'),
                  subtitle: Text(a.timedOut ? 'Timed out' : 'You answered ${a.givenAnswer}'),
                  trailing: Text(
                    '${(a.responseTime.inMilliseconds / 1000).toStringAsFixed(1)}s',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
              )),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => _start(_sequenceLength),
                child: const Text('Practice again'),
              ),
            ),
          ],
        ),
      ],
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
