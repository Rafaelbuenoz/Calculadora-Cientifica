import 'dart:math' as math;
import '../lib/engine.dart';
void main() {
  final calculator = ScientificCalculator(); int passed = 0;
  void expect(String expression, double result, {String mode = 'DEG', double answer = 0}) {
    final actual = calculator.evaluate(expression, mode: mode, answer: answer);
    if ((actual - result).abs() > 1e-9 * math.max(1, result.abs())) throw StateError('$expression: $actual != $result');
    passed++;
  }
  void reject(String expression) {
    try { calculator.evaluate(expression); } on CalculationException { passed++; return; }
    throw StateError('Accepted invalid expression: $expression');
  }
  expect('2+3*4',14); expect('(2+3)*4',20); expect('2^3^2',512);
  expect('-2^2',-4); expect('(-2)^2',4); expect('2^-3',.125);
  expect('sqrt(81)',9); expect('log(1000)',3); expect('ln(e)',1);
  expect('sin(30)',.5); expect('cos(180)',-1); expect('tan(45)',1);
  expect('asin(.5)',30); expect('acos(0)',90); expect('atan(1)',45);
  expect('sin(pi/2)',1,mode:'RAD'); expect('asin(1)',math.pi/2,mode:'RAD');
  expect('5!',120); expect('0!',1); expect('3!^2',36); expect('50%*20',10);
  expect('2pi',2*math.pi); expect('2(3+4)',14); expect('2sin(30)',1);
  expect('1,5+2,5',4); expect('1e3+2',1002); expect('ans*2',14,answer:7);
  expect('abs(-3)',3); expect('exp(0)',1); expect('floor(2.8)',2); expect('ceil(2.1)',3);
  for(final e in ['1/0','sqrt(-1)','ln(0)','acos(2)','tan(90)','(-1)!','2.5!','171!','2+','(2+3','unknown(1)','2**3','alert(1)','1e999','1 2','']) { reject(e); }
  reject('('*70+'1'+')'*70);
  if(formatNumber(1.2300)!='1.23'||formatNumber(0)!='0') throw StateError('Formatting failure');passed++;
  print('PASS: $passed scientific engine checks.');
}
