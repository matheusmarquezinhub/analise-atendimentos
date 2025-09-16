
# Guia de Uso do Sistema de Análise de Atendimentos

## Introdução

Este guia explica como utilizar os scripts SQL para extrair insights do banco de dados de atendimentos.

## Passo a Passo

1. **Configurar o ambiente**  
   - Certifique-se de que o banco de dados `Atendimentos` está disponível no seu SQL Server.  
   - Importe ou crie a tabela `ControleAtendimento` com os dados de atendimento.  
   - Opcionalmente, importe a tabela `Servico` para relacionar tipos de serviço.

2. **Executar consultas**  
   - Abra o script desejado na sua ferramenta SQL (ex: SQL Server Management Studio).  
   - Execute a consulta para obter os resultados.  
   - Analise os dados retornados conforme o objetivo (volume, clientes, financeiro, etc.).

3. **Personalizar consultas**  
   - Ajuste filtros, datas ou colunas conforme sua base de dados.  
   - Adapte nomes de colunas se necessário.

## Exemplo de resultado

Consulta: Volume de atendimentos por mês

| MesReferencia | TotalAtendimentos |
|---------------|-------------------|
| 2024-01       | 150               |
| 2024-02       | 180               |
| 2024-03       | 210               |

---

## Contato

Para dúvidas, abra uma issue ou envie um email para marquuezinmatheus@gmail.com
