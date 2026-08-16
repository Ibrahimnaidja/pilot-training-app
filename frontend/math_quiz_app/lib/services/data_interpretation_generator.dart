import 'dart:math';

import '../models/logic_puzzle.dart';

final Random _defaultRandom = Random();

class _TopicSpec {
  final String domain;
  final String unitLabel;
  final List<String> categoryPool;
  const _TopicSpec({required this.domain, required this.unitLabel, required this.categoryPool});
}

const List<_TopicSpec> _chartTopics = [
  _TopicSpec(
    domain: 'Airport passenger traffic',
    unitLabel: 'thousand passengers',
    categoryPool: ['JFK', 'LAX', 'ORD', 'ATL', 'DFW', 'SFO', 'MIA', 'SEA', 'BOS', 'DEN'],
  ),
  _TopicSpec(
    domain: 'Retail store sales',
    unitLabel: 'thousand \$ in sales',
    categoryPool: ['Downtown', 'Uptown', 'Westside', 'Eastside', 'Northgate', 'Southport', 'Riverside', 'Hilltop'],
  ),
  _TopicSpec(
    domain: 'Product line revenue',
    unitLabel: 'thousand \$ in revenue',
    categoryPool: ['Laptops', 'Tablets', 'Phones', 'Accessories', 'Monitors', 'Wearables', 'Speakers', 'Cameras'],
  ),
  _TopicSpec(
    domain: 'Call center volume',
    unitLabel: 'calls handled',
    categoryPool: ['Team Alpha', 'Team Bravo', 'Team Charlie', 'Team Delta', 'Team Echo', 'Team Foxtrot'],
  ),
  _TopicSpec(
    domain: 'Sports team wins',
    unitLabel: 'wins',
    categoryPool: ['Hawks', 'Falcons', 'Eagles', 'Wolves', 'Bears', 'Tigers', 'Sharks', 'Panthers'],
  ),
  _TopicSpec(
    domain: 'Restaurant orders',
    unitLabel: 'orders',
    categoryPool: ['Location A', 'Location B', 'Location C', 'Location D', 'Location E', 'Location F'],
  ),
];

const List<_TopicSpec> _narrativeTopics = [
  _TopicSpec(
    domain: 'Exam scores',
    unitLabel: 'students with distinction',
    categoryPool: ['Class 9A', 'Class 9B', 'Class 9C', 'Class 10A', 'Class 10B', 'Class 10C'],
  ),
  _TopicSpec(
    domain: 'Ingredient usage across recipes',
    unitLabel: 'kg used',
    categoryPool: ['Flour', 'Sugar', 'Butter', 'Eggs', 'Milk', 'Rice', 'Oats', 'Honey'],
  ),
  _TopicSpec(
    domain: 'Departmental expenses',
    unitLabel: 'thousand \$ spent',
    categoryPool: ['Marketing', 'Engineering', 'Sales', 'HR', 'Operations', 'Support', 'Legal', 'Finance'],
  ),
  _TopicSpec(
    domain: 'Survey responses by age group',
    unitLabel: 'respondents',
    categoryPool: ['18-24', '25-34', '35-44', '45-54', '55+', '65+'],
  ),
];

const List<String> _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

List<String> _generateMonthPeriods(Random random) {
  final start = random.nextInt(12);
  return List.generate(5, (i) => _monthNames[(start + i) % 12]);
}

List<String> _generateQuarterPeriods(Random random) {
  final startQuarter = random.nextInt(4);
  final startYear = 2023 + random.nextInt(2);
  return List.generate(5, (i) {
    final q = (startQuarter + i) % 4 + 1;
    final year = startYear + (startQuarter + i) ~/ 4;
    return 'Q$q $year';
  });
}

List<String> _generatePeriods(Random random) =>
    random.nextBool() ? _generateMonthPeriods(random) : _generateQuarterPeriods(random);

class _Dataset {
  final String topicDomain;
  final String unitLabel;
  final List<String> categories;
  final List<String> periods;
  final List<List<int>> values; // values[categoryIndex][periodIndex]

  const _Dataset({
    required this.topicDomain,
    required this.unitLabel,
    required this.categories,
    required this.periods,
    required this.values,
  });

  int valueAt(int c, int p) => values[c][p];

  int totalAt(int p) {
    var sum = 0;
    for (final row in values) {
      sum += row[p];
    }
    return sum;
  }
}

_Dataset _generateDataset(List<_TopicSpec> topicPool, Random random) {
  final topic = topicPool[random.nextInt(topicPool.length)];
  final categories = (List<String>.from(topic.categoryPool)..shuffle(random)).take(3).toList();
  final periods = _generatePeriods(random);
  final values = List.generate(3, (_) => List.generate(5, (_) => 5 + random.nextInt(46)));
  return _Dataset(
    topicDomain: topic.domain,
    unitLabel: topic.unitLabel,
    categories: categories,
    periods: periods,
    values: values,
  );
}

// ---------------------------------------------------------------------------
// Shared distractor helper
// ---------------------------------------------------------------------------

/// Dedupes candidate wrong-answer strings against the correct answer and
/// each other (comparing the actual displayed text, since that's what would
/// make two options look identical to the user), then pads with the given
/// fallback generator if collisions ate into the supply — this should be
/// vanishingly rare given how the candidates are constructed, but guarantees
/// exactly 3 distinct wrong options regardless.
List<String> _uniqueDistractorTexts(
  String correctText,
  List<String> candidates,
  String Function(int attempt) fallback,
) {
  final seen = <String>{correctText};
  final result = <String>[];
  for (final c in candidates) {
    if (result.length >= 3) break;
    if (seen.add(c)) result.add(c);
  }
  var attempt = 0;
  while (result.length < 3) {
    final candidate = fallback(attempt);
    attempt++;
    if (seen.add(candidate)) result.add(candidate);
  }
  return result;
}

// ---------------------------------------------------------------------------
// Archetypes
// ---------------------------------------------------------------------------

class _ArchetypeResult {
  final String archetype;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String workedCalculation;

  const _ArchetypeResult({
    required this.archetype,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.workedCalculation,
  });
}

int _otherCategoryIndex(int ci, int count, Random random) => (ci + 1 + random.nextInt(count - 1)) % count;

_ArchetypeResult _proportionWithinGroup(_Dataset d, Random random) {
  final pi = random.nextInt(d.periods.length);
  final ci = random.nextInt(d.categories.length);
  final total = d.totalAt(pi);
  final subValue = d.valueAt(ci, pi);
  final correctPercent = (subValue / total * 100).round();
  final otherCi = _otherCategoryIndex(ci, d.categories.length, random);

  final correctText = '$correctPercent%';
  final candidates = [
    '${(subValue / (total - subValue) * 100).round()}%', // used "the rest" as the denominator
    '${(d.valueAt(otherCi, pi) / total * 100).round()}%', // wrong subcategory as numerator
    '$subValue%', // raw count shown as if it were already a percentage
  ];
  final wrongs = _uniqueDistractorTexts(correctText, candidates, (i) => '${correctPercent + (i + 1) * 5}%');

  final options = [correctText, ...wrongs]..shuffle(random);
  return _ArchetypeResult(
    archetype: 'proportionWithinGroup',
    question:
        'What proportion of total ${d.topicDomain.toLowerCase()} in ${d.periods[pi]} was ${d.categories[ci]}?',
    options: options,
    correctIndex: options.indexOf(correctText),
    workedCalculation: '${d.categories[ci]} in ${d.periods[pi]} = $subValue; total that period = $total; '
        '$subValue / $total * 100 = ${(subValue / total * 100).toStringAsFixed(2)} -> rounds to $correctText',
  );
}

_ArchetypeResult _percentageChangeAcrossGroups(_Dataset d, Random random) {
  final ci = random.nextInt(d.categories.length);
  final shuffledPeriods = List.generate(d.periods.length, (i) => i)..shuffle(random);
  final groupA = shuffledPeriods.sublist(0, 2);
  final groupB = shuffledPeriods.sublist(2, 4);

  final sumA = d.valueAt(ci, groupA[0]) + d.valueAt(ci, groupA[1]);
  final sumB = d.valueAt(ci, groupB[0]) + d.valueAt(ci, groupB[1]);
  final rawChange = (sumB - sumA) / sumA * 100;
  final correctPercent = rawChange.round();
  final correctText = correctPercent >= 0 ? '$correctPercent% increase' : '${-correctPercent}% decrease';

  final flippedText = correctPercent >= 0 ? '$correctPercent% decrease' : '${-correctPercent}% increase';
  final wrongDenomPercent = ((sumB - sumA) / sumB * 100).round(); // used the ending total as the denominator
  final wrongDenomText = wrongDenomPercent >= 0 ? '$wrongDenomPercent% increase' : '${-wrongDenomPercent}% decrease';
  final rawDiff = sumB - sumA;
  final rawDiffText = '${rawDiff.abs()}% ${rawDiff >= 0 ? 'increase' : 'decrease'}'; // raw diff, not a percentage

  final candidates = [flippedText, wrongDenomText, rawDiffText];
  final wrongs = _uniqueDistractorTexts(correctText, candidates, (i) {
    final bump = correctPercent + (i + 1) * 3;
    return bump >= 0 ? '$bump% increase' : '${-bump}% decrease';
  });

  final periodALabel = '${d.periods[groupA[0]]} + ${d.periods[groupA[1]]}';
  final periodBLabel = '${d.periods[groupB[0]]} + ${d.periods[groupB[1]]}';
  final options = [correctText, ...wrongs]..shuffle(random);

  return _ArchetypeResult(
    archetype: 'percentageChangeAcrossGroups',
    question: 'What was the percentage increase or decrease in ${d.categories[ci]} comparing '
        '$periodALabel versus $periodBLabel?',
    options: options,
    correctIndex: options.indexOf(correctText),
    workedCalculation: '${d.categories[ci]}: $periodALabel = $sumA, $periodBLabel = $sumB; '
        '($sumB - $sumA) / $sumA * 100 = ${rawChange.toStringAsFixed(2)} -> $correctText',
  );
}

_ArchetypeResult _ratioToTotal(_Dataset d, Random random) {
  final pi = random.nextInt(d.periods.length);
  final ci = random.nextInt(d.categories.length);
  final total = d.totalAt(pi);
  final subValue = d.valueAt(ci, pi);
  final correctRatio = total / subValue;
  final correctText = '1:${correctRatio.toStringAsFixed(2)}';
  final otherCi = _otherCategoryIndex(ci, d.categories.length, random);

  final candidates = [
    '1:${(subValue / total).toStringAsFixed(2)}', // reversed the ratio direction
    '1:${((total - subValue) / subValue).toStringAsFixed(2)}', // used "the rest" instead of the total
    '1:${(total / d.valueAt(otherCi, pi)).toStringAsFixed(2)}', // wrong subcategory
  ];
  final wrongs =
      _uniqueDistractorTexts(correctText, candidates, (i) => '1:${(correctRatio + (i + 1) * 0.3).toStringAsFixed(2)}');

  final options = [correctText, ...wrongs]..shuffle(random);
  return _ArchetypeResult(
    archetype: 'ratioToTotal',
    question: 'What was the ratio of ${d.categories[ci]} in ${d.periods[pi]} compared to the total '
        'for all categories that period?',
    options: options,
    correctIndex: options.indexOf(correctText),
    workedCalculation: '${d.categories[ci]} in ${d.periods[pi]} = $subValue; total = $total; '
        'ratio = $subValue : $total = 1 : ${correctRatio.toStringAsFixed(2)}',
  );
}

_ArchetypeResult _targetShortfall(_Dataset d, Random random) {
  final ci = random.nextInt(d.categories.length);
  final baseIdx = random.nextInt(d.periods.length - 1);
  final targetIdx = baseIdx + 1 + random.nextInt(d.periods.length - baseIdx - 1);

  final baseValue = d.valueAt(ci, baseIdx);
  final actualValue = d.valueAt(ci, targetIdx);
  final pledgeIncrease = random.nextBool();
  final pledgePercent = 10 + random.nextInt(31); // 10-40

  final rawTarget =
      pledgeIncrease ? baseValue * (1 + pledgePercent / 100) : baseValue * (1 - pledgePercent / 100);
  final target = rawTarget.round();
  final surplus = pledgeIncrease ? actualValue - target : target - actualValue;
  final correctText = surplus >= 0 ? 'Exceeded target by $surplus' : 'Missed target by ${-surplus}';

  final flippedText = surplus >= 0 ? 'Missed target by $surplus' : 'Exceeded target by ${-surplus}';
  final flooredTarget = rawTarget.floor();
  final surplusFloored = pledgeIncrease ? actualValue - flooredTarget : flooredTarget - actualValue;
  final flooredText =
      surplusFloored >= 0 ? 'Exceeded target by $surplusFloored' : 'Missed target by ${-surplusFloored}';
  final surplusVsBaseline = pledgeIncrease ? actualValue - baseValue : baseValue - actualValue;
  final baselineText =
      surplusVsBaseline >= 0 ? 'Exceeded target by $surplusVsBaseline' : 'Missed target by ${-surplusVsBaseline}';

  final candidates = [flippedText, flooredText, baselineText];
  final wrongs = _uniqueDistractorTexts(correctText, candidates, (i) {
    final bump = surplus + (i + 1) * 3;
    return bump >= 0 ? 'Exceeded target by $bump' : 'Missed target by ${-bump}';
  });

  final direction = pledgeIncrease ? 'increase' : 'reduce';
  final options = [correctText, ...wrongs]..shuffle(random);

  return _ArchetypeResult(
    archetype: 'targetShortfall',
    question: 'If ${d.categories[ci]} pledged in ${d.periods[baseIdx]} to $direction their '
        '${d.topicDomain.toLowerCase()} by $pledgePercent% by ${d.periods[targetIdx]}, by how much have '
        'they missed or exceeded this target?',
    options: options,
    correctIndex: options.indexOf(correctText),
    workedCalculation: '${d.categories[ci]} baseline (${d.periods[baseIdx]}) = $baseValue; pledge = $direction '
        'by $pledgePercent%; target (${d.periods[targetIdx]}) = $baseValue * '
        '${pledgeIncrease ? '(1 + $pledgePercent/100)' : '(1 - $pledgePercent/100)'} = '
        '${rawTarget.toStringAsFixed(2)} -> rounds to $target; actual = $actualValue; '
        'surplus = ${pledgeIncrease ? 'actual - target' : 'target - actual'} = $surplus -> $correctText',
  );
}

const List<String> dataInterpretationArchetypeNames = [
  'proportionWithinGroup',
  'percentageChangeAcrossGroups',
  'ratioToTotal',
  'targetShortfall',
];

String _buildNarrative(_Dataset d) =>
    'The table below shows ${d.topicDomain.toLowerCase()} (in ${d.unitLabel}) for '
    '${d.categories.join(', ')} across ${d.periods.first} through ${d.periods.last}.';

class DataInterpretationDebugInfo {
  final DataInterpretationPuzzle puzzle;
  final String archetype;
  final String workedCalculation;
  const DataInterpretationDebugInfo(this.puzzle, this.archetype, this.workedCalculation);
}

/// Exposed (not library-private) so verification tooling can inspect which
/// archetype/topic fired and confirm the worked calculation, without that
/// information ever reaching the shipped puzzle model the UI renders from.
DataInterpretationDebugInfo generateDataInterpretationDebugInfo([Random? rng]) {
  final random = rng ?? _defaultRandom;
  final style = random.nextBool() ? DataInterpretationStyle.chart : DataInterpretationStyle.narrative;
  final dataset = _generateDataset(style == DataInterpretationStyle.chart ? _chartTopics : _narrativeTopics, random);

  final archetypeFns = [_proportionWithinGroup, _percentageChangeAcrossGroups, _ratioToTotal, _targetShortfall];
  final result = archetypeFns[random.nextInt(archetypeFns.length)](dataset, random);

  final puzzle = DataInterpretationPuzzle(
    style: style,
    topicDomain: dataset.topicDomain,
    unitLabel: dataset.unitLabel,
    categories: dataset.categories,
    periods: dataset.periods,
    values: dataset.values,
    narrative: style == DataInterpretationStyle.narrative ? _buildNarrative(dataset) : null,
    question: result.question,
    options: result.options,
    correctIndex: result.correctIndex,
  );

  return DataInterpretationDebugInfo(puzzle, result.archetype, result.workedCalculation);
}

DataInterpretationPuzzle generateDataInterpretationPuzzle([Random? rng]) =>
    generateDataInterpretationDebugInfo(rng).puzzle;
