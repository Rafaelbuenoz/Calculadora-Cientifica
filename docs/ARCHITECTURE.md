# Arquitetura

Parser próprio limitado a 256 caracteres, 64 níveis e fatorial de 0 a 170. Não usa eval. A precisão é de ponto flutuante, com até 12 algarismos na apresentação; não é aritmética decimal exata.

Fontes próprias em lib/ e web/main.dart; package:web 1.1.1 fixado no pubspec.lock.

web/ contém interface, tema e fontes locais. scripts/build.mjs executa a compilação e testes sem acessar diretórios da NOXBO. dist/ é saída ignorada. Nenhuma permissão de câmera, microfone, pagamentos ou hardware é necessária. Não foi criado backend ou autenticação artificial.

As demos locais ainda permanecem na NOXBO. Nenhum link foi apontado para hospedagem inexistente. Remoção da origem depende de aprovação após validação e recuperação.
