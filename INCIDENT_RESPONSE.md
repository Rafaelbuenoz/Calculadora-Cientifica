# Resposta a incidentes

1. Registre horário, versão, sintoma e impacto, sem copiar tokens ou dados pessoais para issues.
2. Preserve evidências mínimas em local restrito. Não apague o original nem reescreva histórico compartilhado.
3. Contenha o componente afetado com a menor mudança necessária. Publicação, domínio, permissões e recuperação destrutiva exigem aprovação do proprietário.
4. Se houver credencial real exposta, revogue-a no serviço oficial antes de substituí-la; remover um arquivo não elimina cópias e objetos Git antigos.
5. Corrija em branch isolada, acrescente regressão e execute o build e os testes.
6. Revise a correção, restaure em ambiente separado e valide antes de retornar ao serviço.
7. Rafael decide comunicações a envolvidos e avaliação jurídica de eventual incidente com dados pessoais.
8. Documente causa, linha do tempo, ações e prevenção. Não invente um incidente quando houver apenas uma hipótese ou advisory de dependência.
