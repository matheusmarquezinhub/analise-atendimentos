
# Estrutura do Banco de Dados

## Tabela: ControleAtendimento

| Coluna           | Tipo           | Descrição                              |
|------------------|----------------|--------------------------------------|
| Cliente          | VARCHAR(100)   | Identificação do cliente              |
| Data             | DATETIME       | Data do atendimento                   |
| Valores          | DECIMAL(10,2)  | Valor financeiro do atendimento       |
| Tipo_Atendimento | VARCHAR(50)    | Categoria do atendimento              |
| Servico          | INT            | Código do serviço prestado            |
| Profissional     | VARCHAR(100)   | Nome do profissional responsável     |
| SaoClientes      | VARCHAR(20)    | Indicador se é cliente ('Cliente')   |

## Tabela: Servico

| Coluna     | Tipo          | Descrição                  |
|------------|---------------|----------------------------|
| IDServico  | INT           | Identificador do serviço   |
| Descricao  | VARCHAR(100)  | Nome do tipo de serviço    |

---

## Relacionamentos

- `ControleAtendimento.Servico` referencia `Servico.IDServico`

---

## Observações

- A coluna `Valores` representa o ticket bruto do atendimento.  
- A coluna `SaoClientes` é usada para filtrar registros válidos de clientes.

---

## Contato

Se precisar de ajuda, abra uma issue no repositório ou envie um email para marquuezinmatheus@gmail.com
