import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/logic_puzzle.dart';
import '../services/api_client.dart';
import '../services/logic_puzzle_generator.dart';
import '../services/settings_service.dart';
import '../widgets/data_table_grid.dart';
import '../widgets/grouped_bar_chart.dart';
import '../widgets/shape_diagram.dart';

enum _CategoryFilter { numberSequence, verbal, diagrammatic, dataInterpretation, mixed }

extension on _CategoryFilter {
  String get label => switch (this) {
        _CategoryFilter.numberSequence => 'Number sequences',
        _CategoryFilter.verbal => 'Verbal reasoning',
        _CategoryFilter.diagrammatic => 'Diagrammatic reasoning',
        _CategoryFilter.dataInterpretation => 'Data interpretation',
        _CategoryFilter.mixed => 'Mixed',
      };
}

class LogicTrainerScreen extends StatefulWidget {
  final ApiClient api;
  final SettingsService settings;
  const LogicTrainerScreen({super.key, required this.api, required this.settings});

  @override
  State<LogicTrainerScreen> createState() => _LogicTrainerScreenState();
}

class _LogicTrainerScreenState extends State<LogicTrainerScreen> {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();
  final Random _random = Random();

  _CategoryFilter _filter = _CategoryFilter.mixed;
  LogicPuzzle? _puzzle;
  int? _selectedOptionIndex;

  Timer? _countdownTimer;
  int _secondsLeft = 0;
  int _activeTimeLimit = 0;

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
    _loadNewPuzzle();
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
      final stats = await widget.api.fetchLogicStats();
      if (!mounted) return;
      setState(() {
        _currentStreak = stats.currentStreak;
        _bestStreak = stats.bestStreak;
        _totalCorrect = stats.totalCorrect;
        _totalAttempts = stats.totalAttempts;
      });
    } catch (_) {
      // Non-fatal — the puzzle card will surface connection errors instead.
    }
  }

  LogicCategory _resolveCategory() {
    if (_filter == _CategoryFilter.mixed) {
      return LogicCategory.values[_random.nextInt(LogicCategory.values.length)];
    }
    return switch (_filter) {
      _CategoryFilter.numberSequence => LogicCategory.numberSequence,
      _CategoryFilter.verbal => LogicCategory.verbal,
      _CategoryFilter.diagrammatic => LogicCategory.diagrammatic,
      _CategoryFilter.dataInterpretation => LogicCategory.dataInterpretation,
      _CategoryFilter.mixed => throw StateError('unreachable'),
    };
  }

  void _loadNewPuzzle() {
    _countdownTimer?.cancel();
    final puzzle = generateLogicPuzzle(_resolveCategory(), _random);
    setState(() {
      _puzzle = puzzle;
      _loading = false;
      _errorText = null;
      _feedbackText = null;
      _selectedOptionIndex = null;
      _answerController.clear();
      _awaitingNext = false;
    });
    _answerFocusNode.requestFocus();
    _startCountdown(widget.settings.resolveTimeLimit(puzzle.timeLimitSeconds));
  }

  void _onFilterChanged(_CategoryFilter? filter) {
    if (filter == null) return;
    setState(() => _filter = filter);
    _loadNewPuzzle();
  }

  void _startCountdown(int limit) {
    _countdownTimer?.cancel();
    setState(() {
      _secondsLeft = limit;
      _activeTimeLimit = limit;
    });
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

  Future<void> _applyResult(bool correct, {required String message, required Color color}) async {
    setState(() {
      _feedbackText = message;
      _feedbackColor = color;
      _awaitingNext = true;
    });
    try {
      final result = await widget.api.submitLogicAttempt(_puzzle!.category, correct);
      if (!mounted) return;
      setState(() {
        _currentStreak = result.currentStreak;
        _bestStreak = result.bestStreak;
        _totalCorrect = result.totalCorrect;
        _totalAttempts = result.totalAttempts;
      });
    } catch (_) {
      // Streak display just won't refresh this round; still let them continue.
    }
  }

  Future<void> _handleTimeout() async {
    if (_awaitingNext || _puzzle == null) return;
    final message = switch (_puzzle!) {
      NumberSequencePuzzle p => "Time's up. Next number was ${p.answer}.",
      VerbalPuzzle p => "Time's up. Correct answer: ${p.options[p.correctIndex]}.",
      DiagrammaticPuzzle _ => "Time's up.",
      DataInterpretationPuzzle p => "Time's up. Correct answer: ${p.options[p.correctIndex]}.",
    };
    await _applyResult(false, message: message, color: Colors.red.shade700);
  }

  Future<void> _submitNumberAnswer() async {
    final raw = _answerController.text.trim();
    if (raw.isEmpty) {
      setState(() => _errorText = 'Enter an answer first');
      return;
    }
    final value = int.tryParse(raw);
    if (value == null) {
      setState(() => _errorText = 'Enter a whole number');
      return;
    }
    setState(() => _errorText = null);
    _countdownTimer?.cancel();

    final puzzle = _puzzle as NumberSequencePuzzle;
    final correct = value == puzzle.answer;
    await _applyResult(
      correct,
      message: correct ? 'Correct — next number was ${puzzle.answer}' : 'Not quite — next number was ${puzzle.answer}',
      color: correct ? Colors.green.shade700 : Colors.red.shade700,
    );
  }

  Future<void> _submitOptionAnswer() async {
    if (_selectedOptionIndex == null) {
      setState(() => _errorText = 'Choose an option first');
      return;
    }
    setState(() => _errorText = null);
    _countdownTimer?.cancel();

    final correctIndex = switch (_puzzle!) {
      VerbalPuzzle p => p.correctIndex,
      DiagrammaticPuzzle p => p.correctIndex,
      DataInterpretationPuzzle p => p.correctIndex,
      NumberSequencePuzzle _ => throw StateError('unreachable'),
    };
    final correct = _selectedOptionIndex == correctIndex;
    await _applyResult(
      correct,
      message: correct ? 'Correct!' : 'Not quite.',
      color: correct ? Colors.green.shade700 : Colors.red.shade700,
    );
  }

  void _primaryAction() {
    if (_awaitingNext) {
      _loadNewPuzzle();
      return;
    }
    if (_puzzle is NumberSequencePuzzle) {
      _submitNumberAnswer();
    } else {
      _submitOptionAnswer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logic trainer')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                DropdownButtonFormField<_CategoryFilter>(
                  key: const Key('logic-category-dropdown'),
                  initialValue: _filter,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: _CategoryFilter.values
                      .map((f) => DropdownMenuItem(value: f, child: Text(f.label)))
                      .toList(),
                  onChanged: _onFilterChanged,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatBlock(label: 'score', value: '$_totalCorrect / $_totalAttempts'),
                    _StatBlock(label: 'streak', value: '$_currentStreak'),
                    _StatBlock(label: 'best', value: '$_bestStreak'),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _loading || _puzzle == null
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _buildPuzzleBody(context, _puzzle!),
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
    );
  }

  Widget _buildPuzzleBody(BuildContext context, LogicPuzzle puzzle) {
    return Column(
      children: [
        Text(
          '$_secondsLeft s left',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _secondsLeft <= (_activeTimeLimit * 0.2).ceil() ? Colors.red.shade700 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        switch (puzzle) {
          NumberSequencePuzzle p => _buildNumberSequence(p),
          VerbalPuzzle p => _buildVerbal(p),
          DiagrammaticPuzzle p => _buildDiagrammatic(p),
          DataInterpretationPuzzle p => _buildDataInterpretation(p),
        },
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          Text(_errorText!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
        ],
      ],
    );
  }

  Widget _buildNumberSequence(NumberSequencePuzzle puzzle) {
    return Column(
      children: [
        Text(puzzle.display, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _answerController,
                focusNode: _answerFocusNode,
                autofocus: true,
                enabled: !_awaitingNext,
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: 'Next number', border: OutlineInputBorder()),
                onSubmitted: (_) => _primaryAction(),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: _primaryAction,
              child: Text(_awaitingNext ? 'Next' : 'Check'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerbal(VerbalPuzzle puzzle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          puzzle.prompt,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < puzzle.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _OptionTile(
              selected: _selectedOptionIndex == i,
              revealCorrect: _awaitingNext,
              isCorrectOption: i == puzzle.correctIndex,
              onTap: _awaitingNext ? null : () => setState(() => _selectedOptionIndex = i),
              child: Text(puzzle.options[i], textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            ),
          ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _primaryAction,
          child: Text(_awaitingNext ? 'Next' : 'Check'),
        ),
      ],
    );
  }

  Widget _buildDiagrammatic(DiagrammaticPuzzle puzzle) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: puzzle.exampleFrames.map((f) => ShapeDiagram(spec: f, size: 76)).toList(),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < puzzle.options.length; i++)
              SizedBox(
                width: 88,
                child: _OptionTile(
                  selected: _selectedOptionIndex == i,
                  revealCorrect: _awaitingNext,
                  isCorrectOption: i == puzzle.correctIndex,
                  onTap: _awaitingNext ? null : () => setState(() => _selectedOptionIndex = i),
                  child: ShapeDiagram(spec: puzzle.options[i], size: 60),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _primaryAction,
          child: Text(_awaitingNext ? 'Next' : 'Check'),
        ),
      ],
    );
  }

  Widget _buildDataInterpretation(DataInterpretationPuzzle puzzle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (puzzle.style == DataInterpretationStyle.chart) ...[
          Text(
            puzzle.topicDomain,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Text(
            '(${puzzle.unitLabel})',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          GroupedBarChart(
            categories: puzzle.categories,
            periods: puzzle.periods,
            values: puzzle.values,
            unitLabel: puzzle.unitLabel,
          ),
        ] else ...[
          Text(puzzle.narrative ?? '', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 12),
          DataTableGrid(categories: puzzle.categories, periods: puzzle.periods, values: puzzle.values),
        ],
        const SizedBox(height: 20),
        Text(
          puzzle.question,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < puzzle.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _OptionTile(
              selected: _selectedOptionIndex == i,
              revealCorrect: _awaitingNext,
              isCorrectOption: i == puzzle.correctIndex,
              onTap: _awaitingNext ? null : () => setState(() => _selectedOptionIndex = i),
              child: Text(puzzle.options[i], textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            ),
          ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _primaryAction,
          child: Text(_awaitingNext ? 'Next' : 'Check'),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final Widget child;
  final bool selected;
  final bool revealCorrect;
  final bool isCorrectOption;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.child,
    required this.selected,
    required this.revealCorrect,
    required this.isCorrectOption,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    var border = scheme.outlineVariant;
    Color? fill;
    var borderWidth = 1.0;

    if (revealCorrect && isCorrectOption) {
      border = Colors.green.shade700;
      fill = Colors.green.shade50;
      borderWidth = 2;
    } else if (revealCorrect && selected) {
      border = Colors.red.shade700;
      fill = Colors.red.shade50;
      borderWidth = 2;
    } else if (selected) {
      border = scheme.primary;
      fill = scheme.primaryContainer;
      borderWidth = 2;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: border, width: borderWidth),
          borderRadius: BorderRadius.circular(12),
          color: fill,
        ),
        alignment: Alignment.center,
        child: child,
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
