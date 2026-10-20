# Calculadora-Cientifica

Projeto Dart independente, extraído da NOXBO e preparado para revisão. A interface e as regras originais foram preservadas. Não houve publicação ou deploy desta candidata.

Parser próprio limitado a 256 caracteres, 64 níveis e fatorial de 0 a 170. Não usa eval. A precisão é de ponto flutuante, com até 12 algarismos na apresentação; não é aritmética decimal exata.

## Compilar e testar

Instale Node.js 24 e Dart SDK 3.13.5. Execute `node scripts/build.mjs`. O script executa os testes e gera dist/ e hashes em artifacts/. `--offline` usa dependências já obtidas. `python3 scripts/security_scan.py --history` verifica os arquivos selecionados e histórico alcançável por padrões limitados.

DART_BIN permite informar o executável Dart.

Sirva dist/ em servidor estático local para revisar a interface; abrir HTML por file:// pode impedir módulos. A aplicação não exige serviços externos. A CI está preparada, mas não foi executada no GitHub. As fontes tipográficas e licenças estão incluídas.

Leia SECURITY.md, INCIDENT_RESPONSE.md e docs/. Não há licença da aplicação escolhida automaticamente; as licenças de terceiros não concedem uma licença ao código do proprietário.

## Portabilidade e integridade

Revisão local de 20/10/2026: `.gitattributes` fixa LF nos arquivos de texto autorais e mantém os binários opacos. As licenças OFL de terceiros usam `-text` para preservar exatamente seus bytes e quebras de linha originais. Os hashes verificam os bytes reais; uma divergência não é ignorada nem normalizada para parecer válida. Os manifestos de saída usam `/` nos caminhos em todos os sistemas.

A CI possui matriz Linux/Windows preparada, com Actions fixadas em commits e checkout sem persistência de credenciais. Nenhum resultado remoto é presumido. Não há deploy no workflow.

No Windows, o script usa `dart.exe`; `DART_BIN` deve apontar para um executável, não para um comando de shell ou arquivo `.bat`. O build foi executado em Linux; execução nativa Windows permanece pendente da CI.

Saída estática: `dist/index.html`, JavaScript Dart compilado, CSS, fontes e avisos de terceiros. Esses arquivos são gerados pelo build e entregues separadamente no pacote de revisão; caches, SDK e artefatos de teste não são fontes a versionar.

## Executar a interface local

Depois do build, inicie um servidor estático no diretório de saída, por exemplo:

```sh
python3 -m http.server 8080 --directory dist
```

No Windows com Python Launcher, use `py -m http.server 8080 --directory dist`. Abra `http://localhost:8080/`. Esses comandos são para a sua máquina; não iniciam hospedagem pública, não requerem conta e não enviam dados para a NOXBO. O Python também executa o guard de exposição; ele não é necessário ao visitante do app.
