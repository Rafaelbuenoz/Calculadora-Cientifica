# Ameaças e limites

- Entradas malformadas e custo computacional: limites explícitos e regressões.
- Manipulação de resultados/estado: validação no domínio; dados locais continuam controláveis pelo usuário do navegador.
- XSS: texto apresentado com APIs de texto, sem executar entrada como código.
- Supply chain: versões fixadas, checagem de dependências e Actions com SHA. Advisories devem ser revisados, não ocultados.
- Informação e repúdio: não há conta, trilha autenticada ou garantia de sigilo no localStorage. Não use dados sensíveis reais na demonstração.
- Disponibilidade/recuperação: hashes e fontes recuperáveis; dados do navegador não são backup remoto.

CSP para hospedagem estática deve restringir default/script/style/font à própria origem, connect-src none, object-src none e base-uri none. Uma futura incorporação deve liberar somente a origem do portfólio e rever o sandbox. A validação em navegador e entre origens continua pendente.
