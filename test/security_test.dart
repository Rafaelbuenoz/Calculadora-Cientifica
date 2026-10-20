import 'dart:math' as math;
import '../lib/engine.dart';

void main() {
  final engine = ScientificCalculator();
  final rejected = [' ' * 257, '1' * 257, '(' * 80 + '1' + ')' * 80,
    '+' * 80 + '1', '1/0', '0/0', 'exp(10000)', '1e999', 'sqrt(-1)',
    'log(0)', 'ln(-1)', 'asin(2)', 'acos(-2)', 'tan(90)', '171!',
    '(-1)!', '2.5!', 'eval(1)', '1;2', 'window(1)'];
  for (final input in rejected) {
    try { engine.evaluate(input); throw StateError('Invalid expression accepted'); }
    on CalculationException { /* expected */ }
  }
  if (!engine.evaluate('170!').isFinite || engine.evaluate('1e-999') != 0 || engine.evaluate('1e308') != 1e308) throw StateError('Numeric boundary failed');
  final random = math.Random(42);
  const alphabet = '0123456789+-*/^()!%.e;{}[]xyz';
  for (var i = 0; i < 2000; i++) {
    final input = List.generate(random.nextInt(256) + 1, (_) => alphabet[random.nextInt(alphabet.length)]).join();
    try { if (!engine.evaluate(input).isFinite) throw StateError('Nonfinite result'); }
    on CalculationException { /* invalid inputs must fail safely */ }
  }
  print('PASS: 20 rejected expressions, 3 numeric boundaries, 2000 deterministic malformed inputs.');
}
