enum LogicCategory { numberSequence, diagrammatic, verbal, dataInterpretation }

extension LogicCategoryJson on LogicCategory {
  // Matches the C# enum member names exactly (Program.cs serializes enums via
  // JsonStringEnumConverter with no naming policy, so it's PascalCase as-is —
  // same convention create_problem_screen.dart already uses for MathOperator).
  String get apiValue => switch (this) {
        LogicCategory.numberSequence => 'NumberSequence',
        LogicCategory.diagrammatic => 'Diagrammatic',
        LogicCategory.verbal => 'Verbal',
        LogicCategory.dataInterpretation => 'DataInterpretation',
      };
}

sealed class LogicPuzzle {
  const LogicPuzzle();

  LogicCategory get category;
  int get timeLimitSeconds;
}

class NumberSequencePuzzle extends LogicPuzzle {
  final List<int> terms;
  final int answer;

  const NumberSequencePuzzle({required this.terms, required this.answer});

  @override
  LogicCategory get category => LogicCategory.numberSequence;

  @override
  int get timeLimitSeconds => 20;

  String get display => '${terms.join(', ')}, ?';
}

class VerbalPuzzle extends LogicPuzzle {
  final String prompt;
  final List<String> options;
  final int correctIndex;

  const VerbalPuzzle({required this.prompt, required this.options, required this.correctIndex});

  @override
  LogicCategory get category => LogicCategory.verbal;

  @override
  int get timeLimitSeconds => 30;
}

enum ShapeKind { triangle, square, pentagon, hexagon, heptagon, octagon, circle }

extension ShapeKindSides on ShapeKind {
  // A circle has no "sides" in the polygon sense; 0 is a sentinel that also
  // happens to fall out correctly in the rotation-period formula elsewhere
  // (8 / gcd(0, 8) == 1), matching the physical fact that rotating a circle
  // never looks different.
  int get sides => switch (this) {
        ShapeKind.triangle => 3,
        ShapeKind.square => 4,
        ShapeKind.pentagon => 5,
        ShapeKind.hexagon => 6,
        ShapeKind.heptagon => 7,
        ShapeKind.octagon => 8,
        ShapeKind.circle => 0,
      };
}

/// One renderable "scene": a main shape (sides/fill/rotation/size) optionally
/// paired with a count of small secondary shapes. Used both for the example
/// frames and for the answer options of a diagrammatic puzzle.
class ShapeSpec {
  final ShapeKind shape;
  final bool filled;
  final int rotationSteps;
  final double sizeScale;
  final int secondaryCount;
  final ShapeKind secondaryShape;

  const ShapeSpec({
    required this.shape,
    required this.filled,
    this.rotationSteps = 0,
    this.sizeScale = 1.0,
    this.secondaryCount = 0,
    this.secondaryShape = ShapeKind.triangle,
  });

  ShapeSpec copyWith({
    ShapeKind? shape,
    bool? filled,
    int? rotationSteps,
    double? sizeScale,
    int? secondaryCount,
    ShapeKind? secondaryShape,
  }) =>
      ShapeSpec(
        shape: shape ?? this.shape,
        filled: filled ?? this.filled,
        rotationSteps: rotationSteps ?? this.rotationSteps,
        sizeScale: sizeScale ?? this.sizeScale,
        secondaryCount: secondaryCount ?? this.secondaryCount,
        secondaryShape: secondaryShape ?? this.secondaryShape,
      );
}

class DiagrammaticPuzzle extends LogicPuzzle {
  final List<ShapeSpec> exampleFrames;
  final List<ShapeSpec> options;
  final int correctIndex;

  const DiagrammaticPuzzle({
    required this.exampleFrames,
    required this.options,
    required this.correctIndex,
  });

  @override
  LogicCategory get category => LogicCategory.diagrammatic;

  @override
  int get timeLimitSeconds => 45;
}

enum DataInterpretationStyle { chart, narrative }

/// Either a grouped-bar-chart or a narrative-plus-table presentation of the
/// same underlying data grid (values[categoryIndex][periodIndex]), followed
/// by a multiple-choice question about it.
class DataInterpretationPuzzle extends LogicPuzzle {
  final DataInterpretationStyle style;
  final String topicDomain;
  final String unitLabel;
  final List<String> categories;
  final List<String> periods;
  final List<List<int>> values;
  final String? narrative;
  final String question;
  final List<String> options;
  final int correctIndex;

  const DataInterpretationPuzzle({
    required this.style,
    required this.topicDomain,
    required this.unitLabel,
    required this.categories,
    required this.periods,
    required this.values,
    this.narrative,
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  @override
  LogicCategory get category => LogicCategory.dataInterpretation;

  @override
  int get timeLimitSeconds => 45;

  int valueAt(int categoryIndex, int periodIndex) => values[categoryIndex][periodIndex];

  int totalAt(int periodIndex) {
    var sum = 0;
    for (final row in values) {
      sum += row[periodIndex];
    }
    return sum;
  }
}
