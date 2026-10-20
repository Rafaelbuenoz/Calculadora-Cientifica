# Recuperação e rollback

Preserve o commit de origem e a branch anterior. Use git clone ou git worktree em diretório novo; não use reset destrutivo nem force push. Para reverter uma correção publicada após aprovação, prepare um git revert em nova branch e revise o diff.

Valide o bundle com git bundle verify, clone-o em pasta separada e confira git fsck, hashes, instalação com lockfile e testes. O bundle não é uma cópia de segredos ou de dados persistentes dos visitantes. Guarde a cópia fora do ambiente de trabalho com acesso restrito; cópias somente nesta sessão não constituem uma estratégia 3-2-1.

Não há migração de banco nesta etapa. O estoque utiliza dados demonstrativos do navegador: o backup do código não recupera localStorage de um dispositivo perdido. A restauração explícita dos exemplos apaga alterações locais somente após confirmação na interface.

Verifique restauração a cada trimestre e depois de mudanças na cadeia de build. Nenhuma restauração destrutiva foi executada nesta etapa.
