-- =====================================================
--  SISTEMA DE ANÁLISE DE ATENDIMENTOS
--  Consultas organizadas por domínio de negócio
-- =====================================================

USE Atendimentos;

-- =====================================================
--  [1] ANÁLISE DE VOLUME DE ATENDIMENTOS
-- =====================================================

-- 1.1 Volume Total Geral
-- Descrição: Conta o número total de atendimentos registrados no sistema
SELECT COUNT(*) FROM ControleAtendimento;

-- 1.2 Volume de Atendimentos por Mês
-- Descrição: Agrupa atendimentos por mês/ano para análise temporal de volume
SELECT 
  FORMAT(Data, 'yyyy-MM') AS MesReferencia,
  COUNT(*) AS TotalAtendimentos
FROM ControleAtendimento
GROUP BY FORMAT(Data, 'yyyy-MM')
ORDER BY MesReferencia;

-- 1.3 Volume por Dia da Semana com Percentual
-- Descrição: Mostra distribuição de atendimentos por dia da semana com percentuais
SELECT
    DATENAME(WEEKDAY, Data) AS DiaSemana,
    DATEPART(WEEKDAY, Data) AS OrdemSemana,
    COUNT(*) AS TotalAtendimentos,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS PercentualVolume
FROM ControleAtendimento
GROUP BY DATENAME(WEEKDAY, Data), DATEPART(WEEKDAY, Data)
ORDER BY DATEPART(WEEKDAY, Data);

-- 1.4 Volume por Tipo de Atendimento com Percentual
-- Descrição: Agrupa atendimentos por tipo com participação percentual de cada categoria
SELECT 
    Tipo_Atendimento,
    COUNT(*) AS TotalAtendimentos,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS PercentualTipo
FROM ControleAtendimento
GROUP BY Tipo_Atendimento
ORDER BY TotalAtendimentos DESC;

-- =====================================================
--  [2] ANÁLISE DE CLIENTES
-- =====================================================

-- 2.1 Contagem Total de Clientes Únicos
-- Descrição: Conta quantos clientes distintos existem na base
SELECT COUNT(DISTINCT Cliente) AS ContagemClientes
FROM ControleAtendimento;

-- 2.2 Classificação de Clientes (Novos vs Recorrentes) - Análise Completa
-- Descrição: Segmenta clientes entre novos (1 atendimento) e recorrentes (múltiplos atendimentos)
WITH AnaliseClientes AS (
    SELECT 
        Cliente,
        COUNT(*) AS TotalAtendimentos,
        MIN(Data) AS PrimeiroAtendimento,
        MAX(Data) AS UltimoAtendimento,
        SUM(Valores) AS ValorTotalGasto
    FROM ControleAtendimento
    GROUP BY Cliente
)
SELECT 
    CASE 
        WHEN TotalAtendimentos = 1 THEN 'Cliente Novo'
        ELSE 'Cliente Recorrente'
    END AS TipoCliente,
    COUNT(*) AS QuantidadeClientes,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS PercentualClientes,
    AVG(ValorTotalGasto) AS TicketMedioTipo
FROM AnaliseClientes
GROUP BY CASE WHEN TotalAtendimentos = 1 THEN 'Cliente Novo' ELSE 'Cliente Recorrente' END;

-- 2.3 Detalhamento de Clientes Novos
-- Descrição: Lista clientes com apenas um atendimento, mostrando data e valor do primeiro atendimento
SELECT 
    Cliente,
    Data AS DataPrimeiroAtendimento,
    Valores AS ValorPrimeiroAtendimento
FROM ControleAtendimento c1
WHERE NOT EXISTS (
    SELECT 1 FROM ControleAtendimento c2 
    WHERE c2.Cliente = c1.Cliente AND c2.Data < c1.Data
)
ORDER BY Data DESC;

-- 2.4 Detalhamento de Clientes Recorrentes
-- Descrição: Lista clientes com múltiplos atendimentos, incluindo métricas de valor e frequência
SELECT 
    Cliente,
    COUNT(*) AS TotalAtendimentos,
    MIN(Data) AS PrimeiroAtendimento,
    MAX(Data) AS UltimoAtendimento,
    SUM(Valores) AS ValorTotalGasto,
    AVG(Valores) AS TicketMedio
FROM ControleAtendimento
GROUP BY Cliente
HAVING COUNT(*) > 1
ORDER BY ValorTotalGasto DESC;

-- 2.5 Contagem Simples de Clientes Novos
-- Descrição: Conta apenas o número de clientes com um único atendimento
WITH Novos AS (
SELECT 
	Cliente,
	COUNT(*) AS Contagem
FROM ControleAtendimento
GROUP BY Cliente
HAVING COUNT(*) =1
)
SELECT 
	COUNT(*) AS CONTAGEM_CLIENTES_NOVOS
FROM Novos;

-- 2.6 Lista de Clientes Novos
-- Descrição: Lista todos os clientes que tiveram apenas um atendimento
SELECT 
	Cliente,
	COUNT(*) AS Contagem
FROM ControleAtendimento
GROUP BY Cliente
HAVING COUNT(*) =1;

-- 2.7 Contagem Simples de Clientes Recorrentes
-- Descrição: Conta apenas o número de clientes com múltiplos atendimentos
WITH Recorrentes AS (
SELECT 
	Cliente,
	COUNT(*) AS Contagem
FROM ControleAtendimento
GROUP BY Cliente
HAVING COUNT(*) >1
)
SELECT COUNT(*) AS CONTAGEM_CLIENTES_RECORRENTES
FROM Recorrentes;

-- 2.8 Lista de Clientes Recorrentes
-- Descrição: Lista todos os clientes que tiveram múltiplos atendimentos
SELECT 
	Cliente,
	COUNT(*) AS Contagem
FROM ControleAtendimento
GROUP BY Cliente
HAVING COUNT(*) >1;

-- =====================================================
--  [3] ANÁLISE FINANCEIRA (TICKET E RECEITA)
-- =====================================================

-- 3.1 Indicadores Financeiros Gerais
-- Descrição: Métricas básicas de receita e ticket médio
SELECT 
	SUM(Valores) AS Total,
	AVG(Valores) AS TicketMedio
FROM ControleAtendimento;

-- 3.2 Indicadores Estatísticos Detalhados
-- Descrição: Estatísticas completas incluindo variabilidade e extremos
SELECT 
    COUNT(*) AS TotalAtendimentos,
    SUM(Valores) AS ReceitaTotal,
    AVG(Valores) AS TicketMedio,
    MIN(Valores) AS MenorTicket,
    MAX(Valores) AS MaiorTicket,
    STDEV(Valores) AS DesvioPadraoTicket,
    STDEV(Valores) / AVG(Valores) * 100 AS CoeficienteVariacao
FROM ControleAtendimento;


-- 3.3 Receita por Mês (Performático)
-- Descrição: Agrupa receita mensalmente com otimização de performance
SELECT
    CAST(YEAR(Data) AS VARCHAR(4)) + '-' + 
    RIGHT('0' + CAST(MONTH(Data) AS VARCHAR(2)), 2) AS MesReferencia,
    COUNT(*) AS TotalAtendimentos,
    SUM(Valores) AS ReceitaTotal,
    AVG(Valores) AS TicketMedio
FROM ControleAtendimento
GROUP BY YEAR(Data), MONTH(Data)
ORDER BY YEAR(Data) DESC, MONTH(Data) DESC;

-- 3.4 Ticket por Atendimento Individual
-- Descrição: Lista cada atendimento com seu respectivo valor (ticket bruto)
SELECT 
  Cliente,
  Data,
  Valores AS Ticket
FROM ControleAtendimento;

-- 3.5 Receita Mensal (Versão Simples)
-- Descrição: Versão mais simples para calcular receita mensal (menos performática em grandes volumes)
SELECT 
FORMAT(Data, 'yyyy-MM') AS Mes, 
SUM(Valores) AS Receita 
FROM ControleAtendimento 
GROUP BY FORMAT(Data, 'yyyy-MM') 
ORDER BY Mes DESC;

-- 3.6 Ticket Médio por Tipo de Serviço
-- Descrição: Calcula ticket médio para cada tipo de serviço oferecido
SELECT
	s.Descricao,
	AVG(Valores) AS TicketMedio
FROM ControleAtendimento c
INNER JOIN Servico s
	ON c.Servico = s.IDServico
GROUP BY s.Descricao
ORDER BY TicketMedio DESC;

-- 3.7 Análise Completa por Tipo de Serviço
-- Descrição: Análise abrangente incluindo volume, receita e participação por tipo de serviço
SELECT
    s.Descricao AS TipoServico,
    COUNT(*) AS TotalAtendimentos,
    SUM(c.Valores) AS ReceitaTotal,
    AVG(c.Valores) AS TicketMedio,
    ROUND(SUM(c.Valores) * 100.0 / SUM(SUM(c.Valores)) OVER(), 2) AS PercentualReceita
FROM ControleAtendimento c
INNER JOIN Servico s ON c.Servico = s.IDServico
GROUP BY s.Descricao
ORDER BY ReceitaTotal DESC;

-- 3.8 Performance por Profissional
-- Descrição: Analisa volume de atendimentos e ticket médio por profissional
SELECT
	Profissional,
	COUNT(*) AS TotalAtendimentos,
	AVG(Valores) AS TicketMedio
FROM ControleAtendimento
GROUP BY Profissional
ORDER BY TicketMedio DESC;

-- =====================================================
--  [4] ANÁLISE DE TIPOS DE ATENDIMENTO
-- =====================================================

-- 4.1 Volume por Tipo de Atendimento
-- Descrição: Contagem simples de atendimentos por tipo
SELECT 
	Tipo_Atendimento,
	COUNT(*) AS Contagem
FROM ControleAtendimento
GROUP BY Tipo_Atendimento;

-- 4.2 Frequência e Receita por Tipo de Serviço
-- Descrição: Combina volume e receita por tipo de serviço da tabela de referência
SELECT
	c.Servico,
	s.Descricao AS TipoServico,
	COUNT(*) AS TotalAtendimento,
	SUM(Valores) AS Total
FROM ControleAtendimento c
INNER JOIN Servico s
	ON c.Servico = s.IDServico
GROUP BY c.Servico, s.Descricao
ORDER BY Total DESC;

-- 4.3 Receita Total por Tipo de Atendimento
-- Descrição: Soma da receita agrupada por categoria de atendimento
SELECT
	Tipo_Atendimento,
	SUM(Valores) AS Total
FROM ControleAtendimento
GROUP BY Tipo_Atendimento;

-- =====================================================
--  [5] ANÁLISE DE RETENÇÃO E CHURN
-- =====================================================

-- 5.1 Retenção por Tipo de Serviço
-- Descrição: Calcula taxa de retorno de clientes para cada tipo de serviço inicial
WITH AtendimentosNumerados AS (
  SELECT
    c.Cliente,
    c.Data,
    s.Descricao AS TipoServico,
    ROW_NUMBER() OVER (PARTITION BY c.Cliente ORDER BY c.Data) AS Ordem
  FROM ControleAtendimento c
  INNER JOIN Servico s ON c.Servico = s.IDServico
  WHERE SaoClientes = 'Cliente'
),
Primeiros AS (
  SELECT Cliente, TipoServico FROM AtendimentosNumerados WHERE Ordem = 1
),
Retornos AS (
  SELECT Cliente FROM AtendimentosNumerados WHERE Ordem > 1
)
SELECT 
  p.TipoServico,
  COUNT(*) AS TotalClientes,
  COUNT(r.Cliente) AS ClientesRetornaram,
  ROUND(CAST(COUNT(r.Cliente) AS FLOAT) / COUNT(*) * 100, 2) AS TaxaRetornoPercentual
FROM Primeiros p
LEFT JOIN Retornos r ON p.Cliente = r.Cliente
GROUP BY p.TipoServico
ORDER BY TaxaRetornoPercentual DESC;

-- 5.2 Taxa de Retorno Geral
-- Descrição: Calcula percentual geral de clientes que retornaram para novos atendimentos
WITH Retornos AS (
    SELECT COUNT(DISTINCT TRIM(LOWER(Cliente))) AS qtd_retorno
    FROM ControleAtendimento
    WHERE Cliente IN (
        SELECT Cliente
        FROM ControleAtendimento
        WHERE SaoClientes = 'Cliente'
        GROUP BY Cliente
        HAVING COUNT(*) > 1
    )
),
AtendimentosUnicos AS (
    SELECT COUNT(DISTINCT TRIM(LOWER(Cliente))) AS qtd_total
    FROM ControleAtendimento
    WHERE SaoClientes = 'Cliente'
)
SELECT 
    (CAST(r.qtd_retorno AS FLOAT) / a.qtd_total) * 100 AS taxa_retorno_percentual
FROM Retornos r
CROSS JOIN AtendimentosUnicos a;

-- 5.3 Taxa de Churn Geral
-- Descrição: Calcula percentual de clientes que não retornaram (churn)
WITH Retornos AS (
    SELECT COUNT(DISTINCT TRIM(LOWER(Cliente))) AS qtd_retorno
    FROM ControleAtendimento
    WHERE Cliente IN (
        SELECT Cliente
        FROM ControleAtendimento
        WHERE SaoClientes = 'Cliente'
        GROUP BY Cliente
        HAVING COUNT(*) > 1
    )
),
AtendimentosUnicos AS (
    SELECT COUNT(DISTINCT TRIM(LOWER(Cliente))) AS qtd_total
    FROM ControleAtendimento
    WHERE SaoClientes = 'Cliente'
)
SELECT 
    ROUND(((a.qtd_total - r.qtd_retorno) * 100.0) / a.qtd_total, 2) AS taxa_churn_percentual
FROM Retornos r
CROSS JOIN AtendimentosUnicos a;

-- =====================================================
--  [6] CLASSIFICAÇÃO ABC DE CLIENTES
-- =====================================================

-- 6.1 Classificação ABC Detalhada (Versão Original)
-- Descrição: Classifica clientes em A, B, C baseado na curva de Pareto (80-15-5)
WITH CURVA_ABC AS (
    SELECT
        Cliente,
        SUM(Valores) AS VALORES
    FROM
        ControleAtendimento
    WHERE 
        SaoClientes = 'Cliente'
    GROUP BY
        Cliente
),
BASE AS (
    SELECT
        Cliente,
        VALORES,
        SUM(VALORES) OVER() AS TOTAL_GERAL,
        SUM(VALORES) OVER(
            ORDER BY VALORES DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS ACUM_QTD
    FROM
        CURVA_ABC
)
SELECT *
FROM (
SELECT
    Cliente,
    VALORES,
    CAST(ROUND(100.0 * VALORES / TOTAL_GERAL, 2) AS DECIMAL(10,2)) AS PERC_INDIVIDUAL,
    CAST(ROUND(100.0 * ACUM_QTD / TOTAL_GERAL, 2) AS DECIMAL(10,2)) AS PER_ACUM,
    CASE
        WHEN ACUM_QTD <= (TOTAL_GERAL * 0.80) THEN 'A'
        WHEN ACUM_QTD <= (TOTAL_GERAL * 0.95) THEN 'B'
        ELSE 'C'
    END AS CLASSE
FROM
    BASE
) AS RESULTADO
ORDER BY
    PERC_INDIVIDUAL DESC;

-- 6.2 Classificação ABC Completa com Descrições
-- Descrição: Versão mais detalhada da classificação ABC com rótulos descritivos
WITH CurvaABC AS (
    SELECT
        Cliente,
        SUM(Valores) AS ValorTotal,
        COUNT(*) AS TotalAtendimentos
    FROM ControleAtendimento
    WHERE SaoClientes = 'Cliente'
    GROUP BY Cliente
),
BaseCalculos AS (
    SELECT
        Cliente,
        ValorTotal,
        TotalAtendimentos,
        SUM(ValorTotal) OVER() AS ReceitaTotalGeral,
        SUM(ValorTotal) OVER(
            ORDER BY ValorTotal DESC
            ROWS UNBOUNDED PRECEDING
        ) AS ValorAcumulado
    FROM CurvaABC
)
SELECT
    Cliente,
    ValorTotal,
    TotalAtendimentos,
    ROUND(ValorTotal * 100.0 / ReceitaTotalGeral, 2) AS PercentualIndividual,
    ROUND(ValorAcumulado * 100.0 / ReceitaTotalGeral, 2) AS PercentualAcumulado,
    CASE
        WHEN ValorAcumulado <= (ReceitaTotalGeral * 0.80) THEN 'A - Alta Receita'
        WHEN ValorAcumulado <= (ReceitaTotalGeral * 0.95) THEN 'B - Média Receita'
        ELSE 'C - Baixa Receita'
    END AS ClassificacaoABC
FROM BaseCalculos
ORDER BY ValorTotal DESC;

-- 6.3 Resumo Executivo da Classificação ABC
-- Descrição: Sumariza a distribuição de clientes e receita por classe ABC
WITH CurvaABC AS (
    SELECT
        Cliente,
        SUM(Valores) AS ValorTotal
    FROM ControleAtendimento
    WHERE SaoClientes = 'Cliente'
    GROUP BY Cliente
),
BaseCalculos AS (
    SELECT
        Cliente,
        ValorTotal,
        SUM(ValorTotal) OVER() AS ReceitaTotalGeral,
        SUM(ValorTotal) OVER(ORDER BY ValorTotal DESC ROWS UNBOUNDED PRECEDING) AS ValorAcumulado
    FROM CurvaABC
),
Classificacao AS (
    SELECT
        CASE
            WHEN ValorAcumulado <= (ReceitaTotalGeral * 0.80) THEN 'A'
            WHEN ValorAcumulado <= (ReceitaTotalGeral * 0.95) THEN 'B'
            ELSE 'C'
        END AS Classe,
        ValorTotal,
        Cliente
    FROM BaseCalculos
)
SELECT 
    Classe,
    COUNT(*) AS QuantidadeClientes,
    SUM(ValorTotal) AS ReceitaClasse,
    AVG(ValorTotal) AS TicketMedioClasse,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS PercentualClientes,
    ROUND(SUM(ValorTotal) * 100.0 / SUM(SUM(ValorTotal)) OVER(), 2) AS PercentualReceita
FROM Classificacao
GROUP BY Classe
ORDER BY Classe;

-- =====================================================
--  [7] CONSULTAS DE APOIO E VALIDAÇÃO
-- =====================================================

-- 7.1 Verificação de Integridade dos Dados
-- Descrição: Identifica possíveis problemas de qualidade nos dados
SELECT 
    'Registros com valores nulos ou zerados' AS Verificacao,
    COUNT(*) AS Quantidade
FROM ControleAtendimento
WHERE Valores IS NULL OR Valores <= 0
UNION ALL
SELECT 
    'Registros com datas futuras' AS Verificacao,
    COUNT(*) AS Quantidade
FROM ControleAtendimento
WHERE Data > GETDATE()
UNION ALL
SELECT 
    'Registros com clientes vazios' AS Verificacao,
    COUNT(*) AS Quantidade
FROM ControleAtendimento
WHERE Cliente IS NULL OR TRIM(Cliente) = '';

-- 7.2 Período de Cobertura dos Dados
-- Descrição: Mostra o período temporal coberto pelos dados e a extensão da base
SELECT 
    MIN(Data) AS DataInicial,
    MAX(Data) AS DataFinal,
    DATEDIFF(DAY, MIN(Data), MAX(Data)) AS DiasCobertura,
    DATEDIFF(MONTH, MIN(Data), MAX(Data)) AS MesesCobertura
FROM ControleAtendimento;