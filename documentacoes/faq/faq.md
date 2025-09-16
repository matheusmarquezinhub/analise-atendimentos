# FAQ e Troubleshooting

## Perguntas Frequentes

**P:** Como tratar registros com valores nulos ou zerados?  
**R:** Esses registros podem indicar erros de entrada. Recomenda-se revisar a origem dos dados ou excluir esses registros para análises financeiras.

**P:** Por que alguns clientes aparecem com múltiplos nomes?  
**R:** Pode haver inconsistências no cadastro (ex: espaços, maiúsculas/minúsculas). Use funções de limpeza como `TRIM()` e `LOWER()` para uniformizar, ou incluir ID_Atendimento.

**P:** Como atualizar os scripts para outro banco de dados?  
**R:** Ajuste funções específicas de data e formatação conforme o dialeto SQL do seu banco (ex: MySQL, PostgreSQL).

## Problemas Comuns

- **Datas futuras:** Verifique se o relógio do servidor está correto e se os dados foram inseridos com a data certa.  
- **Performance lenta:** Utilize índices nas colunas usadas em filtros e agrupamentos, como `Data` e `Cliente`.

---

## Contato

Se precisar de ajuda, abra uma issue no repositório ou envie um email para marquuezinmatheus@gmail.com