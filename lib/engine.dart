import 'dart:math' as math;

class CalculationException implements Exception {
  final String message;
  const CalculationException(this.message);
  @override
  String toString() => message;
}

class ScientificCalculator {
  double evaluate(String expression, {String mode = 'DEG', double answer = 0}) {
    if (expression.length > 256) {
      throw const CalculationException('A expressão ficou longa demais.');
    }
    if (expression.trim().isEmpty) {
      throw const CalculationException('Digite uma expressão para calcular.');
    }
    if (!['DEG', 'RAD'].contains(mode)) {
      throw const CalculationException('Escolha DEG ou RAD.');
    }
    final normalized = expression.replaceAll('×', '*').replaceAll('÷', '/')
        .replaceAll('−', '-').replaceAll('π', 'pi').replaceAll(',', '.');
    return _Parser(normalized, mode, answer).parse();
  }
}

String formatNumber(double value) {
  if (!value.isFinite) throw const CalculationException('Resultado fora do intervalo.');
  if (value == 0) return '0';
  final parts = value.toStringAsPrecision(12).split('e');
  String mantissa = parts.first;
  if (mantissa.contains('.')) mantissa = mantissa.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  return parts.length == 1 ? mantissa : '${mantissa}e${int.parse(parts[1])}';
}

class _Parser {
  final String source;
  final String mode;
  final double answer;
  int position = 0;
  int depth = 0;
  _Parser(this.source, this.mode, this.answer);
  String get current { _space(); return position < source.length ? source[position] : ''; }
  void _space() { while (position < source.length && source[position].trim().isEmpty) { position++; } }
  bool _take(String token) { if (current == token) { position++; return true; } return false; }
  double _finite(num value) {
    final result = value.toDouble();
    if (!result.isFinite) throw const CalculationException('Resultado indefinido ou fora do intervalo.');
    return result;
  }
  double parse() {
    final result = _sum();
    if (current.isNotEmpty) throw CalculationException('Confira a expressão perto de “${source.substring(position, math.min(position + 12, source.length))}”.');
    return _finite(result);
  }
  double _sum() {
    var result = _term();
    while (true) {
      if (_take('+')) { result = _finite(result + _term()); }
      else if (_take('-')) { result = _finite(result - _term()); }
      else { return result; }
    }
  }
  double _term() {
    var result = _unary();
    while (true) {
      if (_take('*')) { result = _finite(result * _unary()); }
      else if (_take('/')) {
        final denominator = _unary();
        if (denominator == 0) throw const CalculationException('Não é possível dividir por zero.');
        result = _finite(result / denominator);
      } else if (current == '(' || RegExp(r'[A-Za-z]').hasMatch(current) && current.isNotEmpty) {
        result = _finite(result * _unary());
      } else { return result; }
    }
  }
  double _unary() {
    depth++;
    if (depth > 64) throw const CalculationException('Use uma expressão com menos níveis.');
    try {
      if (_take('+')) return _unary();
      if (_take('-')) return -_unary();
      return _power();
    } finally { depth--; }
  }
  double _power() {
    final value = _postfix();
    return _take('^') ? _finite(math.pow(value, _unary())) : value;
  }
  double _postfix() {
    var value = _primary();
    while (true) {
      if (_take('!')) {
        if (value < 0 || value > 170 || value != value.floorToDouble()) {
          throw const CalculationException('Fatorial aceita inteiros de 0 a 170.');
        }
        double result = 1;
        for (int i = 2; i <= value; i++) { result *= i; }
        value = _finite(result);
      } else if (_take('%')) { value /= 100; }
      else { return value; }
    }
  }
  double _primary() {
    if (_take('(')) {
      final value = _sum();
      if (!_take(')')) throw const CalculationException('Falta fechar um parêntese.');
      return value;
    }
    _space();
    final number = RegExp(r'^(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?').firstMatch(source.substring(position));
    if (number != null) {
      position += number[0]!.length;
      return _finite(double.parse(number[0]!));
    }
    final word = RegExp(r'^[A-Za-z]+').firstMatch(source.substring(position));
    if (word != null) {
      final name = word[0]!.toLowerCase(); position += word[0]!.length;
      if (name == 'pi') return math.pi;
      if (name == 'e') return math.e;
      if (name == 'ans') return _finite(answer);
      if (!_take('(')) throw CalculationException('Use $name(...).');
      final value = _sum();
      if (!_take(')')) throw const CalculationException('Falta fechar um parêntese.');
      return _function(name, value);
    }
    throw const CalculationException('Confira os números, operadores e parênteses.');
  }
  double _function(String name, double value) {
    final radians = mode == 'DEG' ? value * math.pi / 180 : value;
    double angle(double n) => mode == 'DEG' ? n * 180 / math.pi : n;
    switch (name) {
      case 'sin': return _finite(math.sin(radians));
      case 'cos': return _finite(math.cos(radians));
      case 'tan':
        if (math.cos(radians).abs() < 1e-14) throw const CalculationException('A tangente é indefinida para esse ângulo.');
        return _finite(math.tan(radians));
      case 'asin': case 'acos':
        if (value < -1 || value > 1) throw const CalculationException('Use um valor entre -1 e 1.');
        return _finite(angle(name == 'asin' ? math.asin(value) : math.acos(value)));
      case 'atan': return _finite(angle(math.atan(value)));
      case 'sqrt':
        if (value < 0) throw const CalculationException('A raiz quadrada precisa de um valor não negativo.');
        return math.sqrt(value);
      case 'ln': case 'log':
        if (value <= 0) throw const CalculationException('O logaritmo precisa de um valor positivo.');
        return _finite(name == 'ln' ? math.log(value) : math.log(value) / math.ln10);
      case 'exp': return _finite(math.exp(value));
      case 'abs': return value.abs();
      case 'floor': return value.floorToDouble();
      case 'ceil': return value.ceilToDouble();
      default: throw CalculationException('A função “$name” não está disponível.');
    }
  }
}
