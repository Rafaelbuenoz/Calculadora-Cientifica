import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import '../lib/engine.dart';

@JS('noxboDartEvaluate')
external set exportedEvaluator(JSFunction function);
String evaluateBridge(String expression, String mode, double answer) {
  try {
    final value = ScientificCalculator().evaluate(expression, mode: mode, answer: answer);
    return jsonEncode({'ok':true,'value':value,'formatted':formatNumber(value)});
  } on CalculationException catch(error) { return jsonEncode({'ok':false,'error':error.message}); }
}

class CalculatorApp {
  final calculator = ScientificCalculator();
  final input = web.document.querySelector('#expression') as web.HTMLInputElement;
  final result = web.document.querySelector('#result') as web.HTMLOutputElement;
  final message = web.document.querySelector('#message') as web.HTMLElement;
  final historyList = web.document.querySelector('#history') as web.HTMLElement;
  final memoryLabel = web.document.querySelector('#memory-value') as web.HTMLElement;
  final List<Map<String,String>> history = [];
  String mode = 'DEG';
  double answer = 0, memory = 0;
  bool inverse = false;

  void start() {
    restore();
    final buttons = web.document.querySelectorAll('[data-insert], [data-action], [data-mode]');
    for(int i=0;i<buttons.length;i++) {
      final button = buttons.item(i) as web.HTMLButtonElement;
      button.disabled = false;
      button.addEventListener('click',((web.Event event) {
        final token=button.getAttribute('data-insert'), action=button.getAttribute('data-action'), angle=button.getAttribute('data-mode');
        if(token!=null) { insert(token); } else if(action!=null) { act(action); } else if(angle!=null) { setMode(angle); }
      }).toJS);
    }
    (web.document.querySelector('#calculator-form') as web.HTMLFormElement).addEventListener('submit',((web.Event event) { event.preventDefault(); calculate(); }).toJS);
    input.addEventListener('input',((web.Event event) { message.textContent=''; }).toJS);
    web.document.addEventListener('keydown',((web.KeyboardEvent event) {
      if(event.ctrlKey||event.metaKey||event.altKey) return;
      if(event.key=='Enter') { event.preventDefault(); calculate(); return; }
      if(event.key=='Escape') { event.preventDefault(); act('clear'); return; }
      if(event.target==input) return;
      if(event.key=='Backspace') { event.preventDefault(); act('delete'); }
      else if(RegExp(r'^[0-9+\-*/^().,%]$').hasMatch(event.key)) { event.preventDefault(); insert(event.key); }
    }).toJS);
    input.disabled = false;
    setMode(mode); renderHistory(); renderMemory();
    web.document.body?.setAttribute('data-calculator-ready','true');
    web.document.querySelector('#loading')?.remove();
  }

  void insert(String token) {
    final text=input.value, start=input.selectionStart??input.value.length;
    final end=input.selectionEnd??start;
    var prefix=text.substring(0,start);
    final tail=text.substring(end);
    final function=RegExp(r'^[a-z]+\($').hasMatch(token);
    if(RegExp(r'[0-9)!%]$').hasMatch(prefix)&&(function||['pi','e','Ans','('].contains(token))) {
      prefix+='*';
    } else if(RegExp(r'(?:pi|e|Ans|\)|!|%)$').hasMatch(prefix)&&RegExp(r'^[0-9.]').hasMatch(token)) { prefix+='*'; }
    final expression='$prefix$token$tail';
    if(expression.length>256) { message.textContent='A expressão ficou longa demais.'; return; }
    input.value=expression; input.focus();
    final cursor=prefix.length+token.length; input.setSelectionRange(cursor,cursor);
    message.textContent='';
  }

  double? calculate({bool record=true}) {
    try {
      final value=calculator.evaluate(input.value,mode:mode,answer:answer);
      final formatted=formatNumber(value);
      result.value=formatted; answer=value; message.textContent='';
      if(record) {
        final entry={'expression':input.value,'result':formatted,'mode':mode};
        if(history.isEmpty||history.first.toString()!=entry.toString()) history.insert(0,entry);
        if(history.length>15) history.removeRange(15,history.length);
        save(); renderHistory();
      }
      return value;
    } on CalculationException catch(error) { message.textContent=error.message; return null; }
  }

  void setMode(String next) {
    if(!['DEG','RAD'].contains(next)) return;
    mode=next;
    final buttons=web.document.querySelectorAll('[data-mode]');
    for(int i=0;i<buttons.length;i++) {
      final button=buttons.item(i) as web.HTMLElement;
      button.setAttribute('aria-pressed',(button.getAttribute('data-mode')==mode).toString());
    }
    (web.document.querySelector('#angle-label') as web.HTMLElement).textContent=mode=='DEG'?'Ângulos em graus':'Ângulos em radianos';
    save();
  }

  void act(String action) {
    switch(action) {
      case 'equals': calculate(); break;
      case 'clear': input.value=''; result.value='0'; message.textContent=''; input.focus(); break;
      case 'delete':
        final start=input.selectionStart??input.value.length, end=input.selectionEnd??input.value.length;
        final from=start==end?(start>0?start-1:0):start;
        input.value=input.value.substring(0,from)+input.value.substring(end);
        input.focus(); input.setSelectionRange(from,from); message.textContent=''; break;
      case 'square': insert('^2'); break;
      case 'negate':
        final next=input.value.isEmpty?'-':'-('+input.value+')';
        if(next.length<=256) input.value=next;
        input.focus(); break;
      case 'reciprocal':
        final next='1/('+input.value+')';
        if(next.length<=256) input.value=next;
        input.focus(); break;
      case 'inverse':
        inverse=!inverse;
        (web.document.querySelector('[data-action="inverse"]') as web.HTMLElement).setAttribute('aria-pressed',inverse.toString());
        for(final name in ['sin','cos','tan']) {
          final button=web.document.querySelector('[data-function="$name"]') as web.HTMLElement;
          button.setAttribute('data-insert',(inverse?'a':'')+name+'(');
          button.textContent=inverse?'$name⁻¹':name;
        }
        break;
      case 'memory-clear': memory=0; save(); renderMemory(); message.textContent='Memória limpa.'; break;
      case 'memory-recall': insert('('+formatNumber(memory)+')'); break;
      case 'memory-add': case 'memory-subtract':
        final value=input.value.trim().isEmpty?answer:calculate(record:false);
        if(value==null) break;
        final next=action=='memory-add'?memory+value:memory-value;
        if(!next.isFinite) { message.textContent='O valor ultrapassa o intervalo da memória.'; break; }
        memory=next; save(); renderMemory(); message.textContent='Memória atualizada.'; break;
      case 'history-clear': history.clear(); save(); renderHistory(); message.textContent='Histórico limpo.'; break;
      case 'copy': copy(); break;
    }
  }

  Future<void> copy() async {
    try { await web.window.navigator.clipboard.writeText(result.value).toDart; message.textContent='Resultado copiado.'; }
    catch(_) { message.textContent='Selecione o resultado e copie pelo seu dispositivo.'; }
  }
  void renderMemory() { memoryLabel.textContent=memory==0?'Memória vazia':'M = '+formatNumber(memory); }

  void renderHistory() {
    historyList.textContent = '';
    if(history.isEmpty) {
      final empty=web.document.createElement('p') as web.HTMLParagraphElement;
      empty.className='history-empty'; empty.textContent='Seus cálculos aparecem aqui. Toque em um deles para continuar.';
      historyList.appendChild(empty); return;
    }
    for(final entry in history) {
      final button=web.document.createElement('button') as web.HTMLButtonElement;
      button.type='button'; button.className='history-entry';
      final expression=web.document.createElement('span') as web.HTMLSpanElement;
      final value=web.document.createElement('strong') as web.HTMLElement;
      final angle=web.document.createElement('small') as web.HTMLElement;
      expression.textContent=entry['expression']; value.textContent='= '+entry['result']!; angle.textContent=entry['mode'];
      button.appendChild(expression); button.appendChild(value); button.appendChild(angle);
      button.setAttribute('aria-label','Retomar '+entry['expression']!+', resultado '+entry['result']!+', '+entry['mode']!);
      button.addEventListener('click',((web.Event event) {
        input.value=entry['expression']!; setMode(entry['mode']!); input.focus();
        input.setSelectionRange(input.value.length,input.value.length);
      }).toJS);
      historyList.appendChild(button);
    }
  }

  void save() {
    try { web.window.localStorage.setItem('noxbo-calculator-v1',jsonEncode({'mode':mode,'answer':answer,'memory':memory,'history':history})); }
    catch(_) { /* Calculation also works without storage. */ }
  }
  void restore() {
    try {
      final raw=web.window.localStorage.getItem('noxbo-calculator-v1');
      if(raw==null||raw.length>10000) return;
      final data=jsonDecode(raw);
      if(data is! Map) return;
      if(['DEG','RAD'].contains(data['mode'])) mode=data['mode'];
      if(data['answer'] is num&&(data['answer'] as num).isFinite) answer=(data['answer'] as num).toDouble();
      if(data['memory'] is num&&(data['memory'] as num).isFinite) memory=(data['memory'] as num).toDouble();
      final saved=data['history'];
      if(saved is List) {
        for(final entry in saved.take(15)) {
          if(entry is Map&&entry['expression'] is String&&(entry['expression'] as String).length<=256&&entry['result'] is String&&(entry['result'] as String).length<=64&&['DEG','RAD'].contains(entry['mode'])) {
            history.add({'expression':entry['expression'],'result':entry['result'],'mode':entry['mode']});
          }
        }
      }
      result.value=formatNumber(answer);
    } catch(_) { /* Invalid preferences never prevent calculation. */ }
  }
}

void main() {
  exportedEvaluator=evaluateBridge.toJS;
  CalculatorApp().start();
}

