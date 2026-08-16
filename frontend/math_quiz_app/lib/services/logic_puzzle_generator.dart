import 'dart:math';

import '../data/word_bank.dart';
import '../models/logic_puzzle.dart';
import 'data_interpretation_generator.dart';

final Random _defaultRandom = Random();

LogicPuzzle generateLogicPuzzle(LogicCategory category, [Random? rng]) => switch (category) {
      LogicCategory.numberSequence => generateNumberSequencePuzzle(rng),
      LogicCategory.verbal => generateVerbalPuzzle(rng),
      LogicCategory.diagrammatic => generateDiagrammaticPuzzle(rng),
      LogicCategory.dataInterpretation => generateDataInterpretationPuzzle(rng),
    };

// ---------------------------------------------------------------------------
// Number sequences
// ---------------------------------------------------------------------------

NumberSequencePuzzle generateNumberSequencePuzzle([Random? rng]) {
  final random = rng ?? _defaultRandom;
  const generators = [
    _arithmeticSequence,
    _geometricSequence,
    _alternatingStepSequence,
    _increasingDifferenceSequence,
    _squareBasedSequence,
  ];
  return generators[random.nextInt(generators.length)](random);
}

NumberSequencePuzzle _arithmeticSequence(Random random) {
  final start = 1 + random.nextInt(20);
  final step = (1 + random.nextInt(9)) * (random.nextBool() ? 1 : -1);
  final values = List.generate(6, (i) => start + step * i);
  return NumberSequencePuzzle(terms: values.sublist(0, 5), answer: values[5]);
}

NumberSequencePuzzle _geometricSequence(Random random) {
  final start = 1 + random.nextInt(5);
  final ratio = 2 + random.nextInt(2);
  final values = List.generate(6, (i) => start * pow(ratio, i).toInt());
  return NumberSequencePuzzle(terms: values.sublist(0, 5), answer: values[5]);
}

NumberSequencePuzzle _alternatingStepSequence(Random random) {
  final stepA = 1 + random.nextInt(9);
  final stepB = 1 + random.nextInt(9);
  final values = <int>[1 + random.nextInt(20)];
  for (var i = 0; i < 5; i++) {
    values.add(values.last + (i.isEven ? stepA : -stepB));
  }
  return NumberSequencePuzzle(terms: values.sublist(0, 5), answer: values[5]);
}

NumberSequencePuzzle _increasingDifferenceSequence(Random random) {
  final start = 1 + random.nextInt(10);
  final diffStep = 1 + random.nextInt(3);
  var diff = 1 + random.nextInt(5);
  final values = <int>[start];
  for (var i = 0; i < 5; i++) {
    values.add(values.last + diff);
    diff += diffStep;
  }
  return NumberSequencePuzzle(terms: values.sublist(0, 5), answer: values[5]);
}

NumberSequencePuzzle _squareBasedSequence(Random random) {
  final startN = 1 + random.nextInt(4);
  final offset = random.nextInt(5);
  final values = List.generate(6, (i) => (startN + i) * (startN + i) + offset);
  return NumberSequencePuzzle(terms: values.sublist(0, 5), answer: values[5]);
}

// ---------------------------------------------------------------------------
// Verbal reasoning
// ---------------------------------------------------------------------------

final Map<String, List<String>> _wordsByCategory = () {
  final map = <String, List<String>>{};
  for (final entry in wordBank) {
    map.putIfAbsent(entry.category, () => []).add(entry.word);
  }
  return map;
}();

final Map<String, String> _categoryOfWord = () {
  final map = <String, String>{};
  for (final entry in wordBank) {
    map.putIfAbsent(entry.word, () => entry.category);
  }
  return map;
}();

List<String> _sampleWords(int count, Random random, {required Set<String> exclude, String? fromCategory}) {
  final pool = (fromCategory != null ? _wordsByCategory[fromCategory] : wordBank.map((e) => e.word).toList())
          ?.where((w) => !exclude.contains(w)).toList() ??
      [];
  pool.shuffle(random);
  if (pool.length >= count) return pool.take(count).toList();

  final fallback = wordBank.map((e) => e.word).where((w) => !exclude.contains(w) && !pool.contains(w)).toList()
    ..shuffle(random);
  return [...pool, ...fallback].take(count).toList();
}

VerbalPuzzle generateVerbalPuzzle([Random? rng]) {
  final random = rng ?? _defaultRandom;
  const generators = [_generateAnalogy, _generateOddOneOut, _generateSynonymOrAntonym];
  return generators[random.nextInt(generators.length)](random);
}

VerbalPuzzle _generateAnalogy(Random random) {
  final relation = WordRelation.values[random.nextInt(WordRelation.values.length)];
  final pairs = wordPairs.where((p) => p.relation == relation).toList()..shuffle(random);
  final pairA = pairs[0];
  final pairB = pairs[1];

  final category = _categoryOfWord[pairB.b] ?? 'animal';
  final distractors = _sampleWords(3, random, exclude: {pairA.a, pairA.b, pairB.a, pairB.b}, fromCategory: category);

  final options = [pairB.b, ...distractors]..shuffle(random);
  final correctIndex = options.indexOf(pairB.b);

  return VerbalPuzzle(
    prompt: '${pairA.a} is to ${pairA.b} as ${pairB.a} is to ?',
    options: options,
    correctIndex: correctIndex,
  );
}

VerbalPuzzle _generateOddOneOut(Random random) {
  final categories = _wordsByCategory.keys.where((c) => (_wordsByCategory[c]?.length ?? 0) >= 4).toList()
    ..shuffle(random);
  final mainCategory = categories[0];
  final oddCategory = categories.firstWhere((c) => c != mainCategory, orElse: () => categories[1]);

  final mainWords = _sampleWords(3, random, exclude: const {}, fromCategory: mainCategory);
  final oddWords = _sampleWords(1, random, exclude: mainWords.toSet(), fromCategory: oddCategory);
  final oddWord = oddWords.first;

  final options = [...mainWords, oddWord]..shuffle(random);
  final correctIndex = options.indexOf(oddWord);

  return VerbalPuzzle(
    prompt: 'Which word does not belong with the others?',
    options: options,
    correctIndex: correctIndex,
  );
}

VerbalPuzzle _generateSynonymOrAntonym(Random random) {
  final relation = random.nextBool() ? WordRelation.synonym : WordRelation.antonym;
  final pairs = wordPairs.where((p) => p.relation == relation).toList()..shuffle(random);
  final pair = pairs.first;
  final promptWord = random.nextBool() ? pair.a : pair.b;
  final answer = promptWord == pair.a ? pair.b : pair.a;

  final category = _categoryOfWord[answer] ?? 'trait';
  final distractors = _sampleWords(3, random, exclude: {promptWord, answer}, fromCategory: category);

  final options = [answer, ...distractors]..shuffle(random);
  final correctIndex = options.indexOf(answer);

  final verb = relation == WordRelation.synonym ? 'closest in meaning to' : 'most opposite in meaning to';
  return VerbalPuzzle(
    prompt: "Which word is $verb '$promptWord'?",
    options: options,
    correctIndex: correctIndex,
  );
}

// ---------------------------------------------------------------------------
// Diagrammatic / logical reasoning
// ---------------------------------------------------------------------------

const List<ShapeKind> _polygonPool = [
  ShapeKind.triangle,
  ShapeKind.square,
  ShapeKind.pentagon,
  ShapeKind.hexagon,
  ShapeKind.heptagon,
  ShapeKind.octagon,
];

const List<ShapeKind> _shapeCycle = [ShapeKind.square, ShapeKind.triangle, ShapeKind.circle];

// A regular N-sided polygon drawn with a plain fill/outline (no corner
// markings) repeats its appearance every (360 / N) degrees. Our rotation
// steps are 1/8-turns, so the number of steps after which two rotations
// render identically is 8 / gcd(sides, 8) — e.g. a square (4 sides) repeats
// every 2 steps, an octagon (8 sides) repeats every single step (rotating
// one at all is never visible), and a circle (sentinel sides=0) always
// repeats immediately. Comparing raw ShapeSpec fields misses this; comparing
// the *rendered* signature (rotation reduced to its visual class) catches it.
int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

int _rotationPeriod(int sides) => 8 ~/ _gcd(sides, 8);

class _VisualSignature {
  final ShapeKind shape;
  final bool filled;
  final int rotationClass;
  final double sizeScale;
  final int secondaryCount;
  final ShapeKind secondaryShape;

  const _VisualSignature({
    required this.shape,
    required this.filled,
    required this.rotationClass,
    required this.sizeScale,
    required this.secondaryCount,
    required this.secondaryShape,
  });

  @override
  bool operator ==(Object other) =>
      other is _VisualSignature &&
      shape == other.shape &&
      filled == other.filled &&
      rotationClass == other.rotationClass &&
      sizeScale == other.sizeScale &&
      secondaryCount == other.secondaryCount &&
      secondaryShape == other.secondaryShape;

  @override
  int get hashCode =>
      Object.hash(shape, filled, rotationClass, sizeScale, secondaryCount, secondaryShape);
}

_VisualSignature _renderedSignature(ShapeSpec s) => _VisualSignature(
      shape: s.shape,
      filled: s.filled,
      rotationClass: s.rotationSteps % _rotationPeriod(s.shape.sides),
      sizeScale: s.sizeScale,
      secondaryCount: s.secondaryCount,
      secondaryShape: s.secondaryShape,
    );

bool _looksIdentical(ShapeSpec a, ShapeSpec b) => _renderedSignature(a) == _renderedSignature(b);

int _countWithParity(bool odd, Random random) {
  final base = 1 + random.nextInt(3) * 2; // 1, 3, 5
  return odd ? base : base + 1; // 1,3,5 or 2,4,6
}

// --- shared "make this option wrong in exactly one visible way" helpers ---

ShapeSpec _violateFill(ShapeSpec s, Random random) => s.copyWith(filled: !s.filled);

ShapeSpec Function(ShapeSpec, Random) _violateShapeAmong(List<ShapeKind> pool) => (s, random) {
      final others = pool.where((k) => k != s.shape).toList();
      return s.copyWith(shape: others[random.nextInt(others.length)]);
    };

ShapeSpec _violateCount(ShapeSpec s, Random random) {
  final delta = 1 + random.nextInt(3);
  final wrongCount = random.nextBool() ? s.secondaryCount + delta : max(0, s.secondaryCount - delta);
  return s.copyWith(secondaryCount: wrongCount);
}

ShapeSpec _violateRotation(ShapeSpec s, Random random) {
  final period = _rotationPeriod(s.shape.sides);
  if (period <= 1) return _violateFill(s, random); // rotation is never visible for this shape
  final offset = 1 + random.nextInt(period - 1);
  return s.copyWith(rotationSteps: (s.rotationSteps + offset) % 8);
}

List<ShapeSpec> _threeDistinctDistractors(
  ShapeSpec correct,
  List<ShapeSpec Function(ShapeSpec, Random)> violators,
  Random random,
) {
  final options = <ShapeSpec>[];
  var attempts = 0;
  while (options.length < 3 && attempts < 200) {
    attempts++;
    final violator = violators[random.nextInt(violators.length)];
    final candidate = violator(correct, random);
    if (!_looksIdentical(candidate, correct) && !options.any((o) => _looksIdentical(o, candidate))) {
      options.add(candidate);
    }
  }
  return options;
}

List<ShapeSpec> _finishOptions(ShapeSpec correct, List<ShapeSpec> distractors, Random random) =>
    [correct, ...distractors]..shuffle(random);

// --- 1. color swap: the shape alternates fill color each frame ---

DiagrammaticPuzzle generateColorSwapRule([Random? rng]) {
  final random = rng ?? _defaultRandom;
  final shape = _polygonPool[random.nextInt(_polygonPool.length)];
  final startFilled = random.nextBool();
  final secondaryCount = 1 + random.nextInt(3);
  final frameCount = 2 + random.nextInt(2);

  ShapeSpec frameAt(int n) => ShapeSpec(
        shape: shape,
        filled: n.isEven ? startFilled : !startFilled,
        secondaryCount: secondaryCount,
        secondaryShape: ShapeKind.triangle,
      );

  final exampleFrames = List.generate(frameCount, frameAt);
  final correct = frameAt(frameCount);
  final distractors = _threeDistinctDistractors(
    correct,
    [_violateFill, _violateShapeAmong(_polygonPool), _violateCount],
    random,
  );
  final options = _finishOptions(correct, distractors, random);
  return DiagrammaticPuzzle(
    exampleFrames: exampleFrames,
    options: options,
    correctIndex: options.indexWhere((o) => identical(o, correct)),
  );
}

// --- 2. rotation: the shape rotates by a fixed angle each frame ---

DiagrammaticPuzzle generateRotationRule([Random? rng]) {
  final random = rng ?? _defaultRandom;

  ShapeKind shape;
  int rotateStep;
  do {
    // A step that's a multiple of the shape's rotation period would make
    // every frame render identically — pick again until it actually moves.
    shape = _polygonPool[random.nextInt(_polygonPool.length)];
    rotateStep = 1 + random.nextInt(3);
  } while (rotateStep % _rotationPeriod(shape.sides) == 0);

  final startFilled = random.nextBool();
  final secondaryCount = 1 + random.nextInt(3);
  final frameCount = 2 + random.nextInt(2);

  ShapeSpec frameAt(int n) => ShapeSpec(
        shape: shape,
        filled: startFilled,
        rotationSteps: (n * rotateStep) % 8,
        secondaryCount: secondaryCount,
        secondaryShape: ShapeKind.triangle,
      );

  final exampleFrames = List.generate(frameCount, frameAt);
  final correct = frameAt(frameCount);
  final distractors = _threeDistinctDistractors(correct, [_violateRotation, _violateFill, _violateCount], random);
  final options = _finishOptions(correct, distractors, random);
  return DiagrammaticPuzzle(
    exampleFrames: exampleFrames,
    options: options,
    correctIndex: options.indexWhere((o) => identical(o, correct)),
  );
}

// --- 3. count progression: a secondary element's count changes by a fixed amount each frame ---

DiagrammaticPuzzle generateCountProgressionRule([Random? rng]) {
  final random = rng ?? _defaultRandom;
  final shape = _polygonPool[random.nextInt(_polygonPool.length)];
  final startFilled = random.nextBool();
  final startCount = 1 + random.nextInt(3);
  final countStep = 1 + random.nextInt(2);
  final frameCount = 2 + random.nextInt(2);

  ShapeSpec frameAt(int n) => ShapeSpec(
        shape: shape,
        filled: startFilled,
        secondaryCount: startCount + n * countStep,
        secondaryShape: ShapeKind.triangle,
      );

  final exampleFrames = List.generate(frameCount, frameAt);
  final correct = frameAt(frameCount);
  final distractors = _threeDistinctDistractors(
    correct,
    [_violateCount, _violateFill, _violateShapeAmong(_polygonPool)],
    random,
  );
  final options = _finishOptions(correct, distractors, random);
  return DiagrammaticPuzzle(
    exampleFrames: exampleFrames,
    options: options,
    correctIndex: options.indexWhere((o) => identical(o, correct)),
  );
}

// --- 4. parity dependency: sides parity determines fill color and secondary count ---
// (the real Sova example this models: "large shape with even sides = white,
// paired with an odd number of small shapes; odd sides = black, paired with
// an even number of small shapes")

class _ParityRule {
  final bool oddSidesIsFilled;
  final bool oddSidesHasOddSecondaryCount;
  const _ParityRule(this.oddSidesIsFilled, this.oddSidesHasOddSecondaryCount);
}

ShapeSpec _ruleFollowingShape(_ParityRule rule, bool oddSides, Random random) {
  final pool = _polygonPool.where((s) => s.sides.isOdd == oddSides).toList();
  final shape = pool[random.nextInt(pool.length)];
  final filled = oddSides ? rule.oddSidesIsFilled : !rule.oddSidesIsFilled;
  final wantOddCount = oddSides ? rule.oddSidesHasOddSecondaryCount : !rule.oddSidesHasOddSecondaryCount;
  final secondaryCount = _countWithParity(wantOddCount, random);
  return ShapeSpec(shape: shape, filled: filled, secondaryCount: secondaryCount, secondaryShape: ShapeKind.triangle);
}

ShapeSpec _ruleViolatingShape(_ParityRule rule, Random random) {
  final oddSides = random.nextBool();
  final correct = _ruleFollowingShape(rule, oddSides, random);
  if (random.nextBool()) {
    return correct.copyWith(filled: !correct.filled);
  }
  final wantOddCount = oddSides ? rule.oddSidesHasOddSecondaryCount : !rule.oddSidesHasOddSecondaryCount;
  return correct.copyWith(secondaryCount: _countWithParity(!wantOddCount, random));
}

DiagrammaticPuzzle generateParityDependencyRule([Random? rng]) {
  final random = rng ?? _defaultRandom;
  final rule = _ParityRule(random.nextBool(), random.nextBool());

  final frameCount = 2 + random.nextInt(2);
  final branchPattern = [true, false, true]..shuffle(random);
  final exampleFrames = List.generate(frameCount, (i) => _ruleFollowingShape(rule, branchPattern[i], random));

  final correct = _ruleFollowingShape(rule, random.nextBool(), random);
  final distractors = _threeDistinctDistractors(correct, [(s, r) => _ruleViolatingShape(rule, r)], random);
  final options = _finishOptions(correct, distractors, random);
  return DiagrammaticPuzzle(
    exampleFrames: exampleFrames,
    options: options,
    correctIndex: options.indexWhere((o) => identical(o, correct)),
  );
}

// --- 5. shape type swap: the main shape cycles through a fixed set each frame ---

DiagrammaticPuzzle generateShapeTypeSwapRule([Random? rng]) {
  final random = rng ?? _defaultRandom;
  final startIndex = random.nextInt(_shapeCycle.length);
  final startFilled = random.nextBool();
  final secondaryCount = 1 + random.nextInt(3);
  final frameCount = 2 + random.nextInt(2);

  ShapeSpec frameAt(int n) => ShapeSpec(
        shape: _shapeCycle[(startIndex + n) % _shapeCycle.length],
        filled: startFilled,
        secondaryCount: secondaryCount,
        secondaryShape: ShapeKind.triangle,
      );

  final exampleFrames = List.generate(frameCount, frameAt);
  final correct = frameAt(frameCount);
  final distractors =
      _threeDistinctDistractors(correct, [_violateShapeAmong(_shapeCycle), _violateFill, _violateCount], random);
  final options = _finishOptions(correct, distractors, random);
  return DiagrammaticPuzzle(
    exampleFrames: exampleFrames,
    options: options,
    correctIndex: options.indexWhere((o) => identical(o, correct)),
  );
}

// --- 6. combined: two of the above five rules must hold simultaneously ---
// (parityDependency's shape/fill/count are already fully coupled to each
// other, so it only ever combines with rotation — every other pairing is
// two independent, non-conflicting attributes and composes freely)

enum _Mechanism { colorSwap, rotation, countProgression, parityDependency, shapeTypeSwap }

const List<(_Mechanism, _Mechanism)> _validCombinedPairs = [
  (_Mechanism.colorSwap, _Mechanism.rotation),
  (_Mechanism.colorSwap, _Mechanism.countProgression),
  (_Mechanism.colorSwap, _Mechanism.shapeTypeSwap),
  (_Mechanism.rotation, _Mechanism.countProgression),
  (_Mechanism.rotation, _Mechanism.shapeTypeSwap),
  (_Mechanism.rotation, _Mechanism.parityDependency),
  (_Mechanism.countProgression, _Mechanism.shapeTypeSwap),
];

typedef _FrameDriver = ShapeSpec Function(ShapeSpec base, int n);

_FrameDriver _colorSwapDriver(bool startFilled) =>
    (base, n) => base.copyWith(filled: n.isEven ? startFilled : !startFilled);

_FrameDriver _rotationDriver(ShapeKind? fixedShape, Random random) {
  var rotateStep = 1 + random.nextInt(3);
  // Only retry if some rotateStep could actually be non-degenerate for this
  // shape (period > 1) — for an octagon (period 1) every step is a no-op,
  // so retrying would loop forever. When combined with another mechanism
  // that's fine: that mechanism alone still guarantees visible change.
  if (fixedShape != null && _rotationPeriod(fixedShape.sides) > 1) {
    while (rotateStep % _rotationPeriod(fixedShape.sides) == 0) {
      rotateStep = 1 + random.nextInt(3);
    }
  }
  return (base, n) => base.copyWith(rotationSteps: (n * rotateStep) % 8);
}

_FrameDriver _countProgressionDriver(int startCount, Random random) {
  final countStep = 1 + random.nextInt(2);
  return (base, n) => base.copyWith(secondaryCount: startCount + n * countStep);
}

_FrameDriver _shapeTypeSwapDriver(Random random) {
  final startIndex = random.nextInt(_shapeCycle.length);
  return (base, n) => base.copyWith(shape: _shapeCycle[(startIndex + n) % _shapeCycle.length]);
}

DiagrammaticPuzzle generateCombinedRule([Random? rng]) {
  final random = rng ?? _defaultRandom;
  final pair = _validCombinedPairs[random.nextInt(_validCombinedPairs.length)];
  final mechanisms = [pair.$1, pair.$2];

  if (mechanisms.contains(_Mechanism.parityDependency)) {
    return _combineParityWithRotation(random);
  }
  return _combineFrameDrivers(mechanisms, random);
}

DiagrammaticPuzzle _combineFrameDrivers(List<_Mechanism> mechanisms, Random random) {
  final usesShapeCycle = mechanisms.contains(_Mechanism.shapeTypeSwap);
  // When rotation is paired with a fixed (non-cycling) shape, a low-period
  // shape (square: period 2, octagon: period 1) leaves too few visually
  // distinct rotation offsets — combined with the other mechanism's own
  // single-value violator (e.g. colorSwap's fill toggle only has 1 possible
  // alternative), there may not be enough distinct values to fill 3
  // distractors. Restricting to period >= 3 shapes guarantees plenty.
  final rotationInvolved = mechanisms.contains(_Mechanism.rotation);
  final fixedShapePool = (!usesShapeCycle && rotationInvolved)
      ? _polygonPool.where((s) => _rotationPeriod(s.sides) >= 3).toList()
      : _polygonPool;
  final baseShape = usesShapeCycle
      ? _shapeCycle[random.nextInt(_shapeCycle.length)]
      : fixedShapePool[random.nextInt(fixedShapePool.length)];
  final baseFilled = random.nextBool();
  final baseCount = 1 + random.nextInt(3);
  final baseSpec =
      ShapeSpec(shape: baseShape, filled: baseFilled, secondaryCount: baseCount, secondaryShape: ShapeKind.triangle);

  final violators = <ShapeSpec Function(ShapeSpec, Random)>[];
  final drivers = <_FrameDriver>[];
  for (final m in mechanisms) {
    switch (m) {
      case _Mechanism.colorSwap:
        drivers.add(_colorSwapDriver(baseFilled));
        violators.add(_violateFill);
      case _Mechanism.rotation:
        drivers.add(_rotationDriver(usesShapeCycle ? null : baseShape, random));
        violators.add(_violateRotation);
      case _Mechanism.countProgression:
        drivers.add(_countProgressionDriver(baseCount, random));
        violators.add(_violateCount);
      case _Mechanism.shapeTypeSwap:
        drivers.add(_shapeTypeSwapDriver(random));
        violators.add(_violateShapeAmong(_shapeCycle));
      case _Mechanism.parityDependency:
        throw StateError('parityDependency is combined separately');
    }
  }

  ShapeSpec frameAt(int n) {
    var spec = baseSpec;
    for (final driver in drivers) {
      spec = driver(spec, n);
    }
    return spec;
  }

  final frameCount = 2 + random.nextInt(2);
  final exampleFrames = List.generate(frameCount, frameAt);
  final correct = frameAt(frameCount);
  final distractors = _threeDistinctDistractors(correct, violators, random);
  final options = _finishOptions(correct, distractors, random);
  return DiagrammaticPuzzle(
    exampleFrames: exampleFrames,
    options: options,
    correctIndex: options.indexWhere((o) => identical(o, correct)),
  );
}

DiagrammaticPuzzle _combineParityWithRotation(Random random) {
  final rule = _ParityRule(random.nextBool(), random.nextBool());
  final rotateStep = 1 + random.nextInt(3);

  final frameCount = 2 + random.nextInt(2);
  final branchPattern = [true, false, true]..shuffle(random);
  final exampleFrames = [
    for (var i = 0; i < frameCount; i++)
      _ruleFollowingShape(rule, branchPattern[i], random).copyWith(rotationSteps: (i * rotateStep) % 8),
  ];

  final correct =
      _ruleFollowingShape(rule, random.nextBool(), random).copyWith(rotationSteps: (frameCount * rotateStep) % 8);

  final distractors = _threeDistinctDistractors(
    correct,
    [
      (s, r) => _ruleViolatingShape(rule, r).copyWith(rotationSteps: correct.rotationSteps),
      _violateRotation,
    ],
    random,
  );
  final options = _finishOptions(correct, distractors, random);
  return DiagrammaticPuzzle(
    exampleFrames: exampleFrames,
    options: options,
    correctIndex: options.indexWhere((o) => identical(o, correct)),
  );
}

// --- picker: uniformly random among all 6 named generators above ---

typedef _DiagrammaticGenerator = DiagrammaticPuzzle Function(Random);

const List<_DiagrammaticGenerator> _diagrammaticGenerators = [
  generateColorSwapRule,
  generateRotationRule,
  generateCountProgressionRule,
  generateParityDependencyRule,
  generateShapeTypeSwapRule,
  generateCombinedRule,
];

const List<String> diagrammaticGeneratorNames = [
  'generateColorSwapRule',
  'generateRotationRule',
  'generateCountProgressionRule',
  'generateParityDependencyRule',
  'generateShapeTypeSwapRule',
  'generateCombinedRule',
];

DiagrammaticPuzzle generateDiagrammaticPuzzle([Random? rng]) {
  final random = rng ?? _defaultRandom;
  final index = random.nextInt(_diagrammaticGenerators.length);
  // ignore: avoid_print
  print('[LogicTrainer] diagrammatic generator: ${diagrammaticGeneratorNames[index]}');
  return _diagrammaticGenerators[index](random);
}
