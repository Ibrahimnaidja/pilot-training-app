enum PracticeOperator { add, subtract }

class PracticeProblem {
  final int num1;
  final int num2;
  final PracticeOperator operator;

  const PracticeProblem({required this.num1, required this.num2, required this.operator});

  int get correctAnswer => operator == PracticeOperator.add ? num1 + num2 : num1 - num2;

  String get displayExpression =>
      operator == PracticeOperator.add ? '$num1 + $num2' : '$num1 − $num2';
}

class AnsweredQuestion {
  final PracticeProblem problem;
  final int? givenAnswer;
  final bool correct;
  final bool timedOut;
  final Duration responseTime;

  const AnsweredQuestion({
    required this.problem,
    required this.givenAnswer,
    required this.correct,
    required this.timedOut,
    required this.responseTime,
  });
}
