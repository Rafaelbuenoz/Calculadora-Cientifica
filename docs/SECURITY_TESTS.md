# Evidência da revisão independente — 20/10/2026

Executados em cópia isolada: Dart 3.13.5 com checksum oficial do SDK conferido, `pub get --enforce-lockfile`, `dart analyze --fatal-infos`, 49 verificações do motor, 20 rejeições, 3 limites numéricos e 2.000 entradas malformadas determinísticas, tanto na VM quanto em JavaScript compilado. Todos passaram.

O JavaScript da interface compilado coincide byte a byte com a candidata NOXBO SHIELD: SHA-256 `b0ea50601ac974afee5bbfb9c28bd2b6c07b9023c20e91a87740220ca4747e81`.

Navegador Chromium local: `sin(30)+sqrt(16)` resultou em 4.5; divisão por zero apresentou erro sem apagar o resultado anterior; `(2+3)*4` resultou em 20. Não houve overflow da página nos frames de 390 e 1000 px. O teste numérico usa texto renderizado do DOM; a captura de tela retornou pintura antiga do resultado. Não foram observados erros ou avisos atribuíveis à aplicação no console capturado.

Consulta OSV de `web` 1.1.1 não retornou advisories. O lockfile e os avisos BSD/OFL foram preservados. Ausência de advisory não prova ausência de vulnerabilidades.

## Escopo e limitações

Guard de exposição por padrões, revisão dos arquivos selecionados, conteúdo dos blobs e metadados do histórico independente. A árvore para publicação não inclui ferramentas internas, credenciais, SDKs, caches, logs ou o histórico privado completo da NOXBO. O contato comercial de segurança e a referência documental ao commit de origem são intencionais.

Não executados: Windows nativo, dispositivo móvel físico, tecnologia assistiva, CI GitHub, CodeQL, enforcement CSP/headers na hospedagem e deploy público. O preview local não comprova a configuração HTTP de produção. Nenhuma alegação de segurança absoluta, conformidade ASVS ou nível SLSA.

A comparação da árvore detectou a normalização automática de CRLF numa licença OFL. A candidata interrompida não foi aceita como íntegra. `web/fonts/OFL-*.txt -text` preserva os avisos upstream byte a byte; a verificação de checkout considera essa exceção explícita, sem ignorar diferenças de hash.
