# Power BI + BigQuery

Este documento registra como conectar o Power BI ao BigQuery neste projeto e qual modelagem inicial usar para construir o dashboard analitico.

## Objetivo

O Power BI deve consumir a camada analitica final gerada pelo dbt no dataset `revops`, sem CSV, sem export manual e sem transformacao paralela fora da stack principal.

Fluxo esperado:

```text
Airflow
   -> BigQuery raw
   -> dbt
   -> BigQuery analytics (revops)
   -> Power BI
```

## Dataset de Consumo

Projeto GCP:

- `revops-analytics-personal`

Dataset analytics:

- `revops`

## Tabelas Recomendadas

Este projeto vai usar apenas `facts` e `dimensions`, porque essa abordagem representa melhor um modelo semantico profissional e mais proximo de BI corporativo.

Carregue estas tabelas no Power BI:

- `fact_deals`
- `fact_subscriptions`
- `fact_mrr_monthly`
- `fact_funnel_conversion`
- `dim_companies`
- `dim_plans`
- `dim_stages`
- `dim_dates`

## Semantica das Tabelas

### Facts

- `fact_deals`: fato de pipeline comercial em nivel de deal. Cada linha representa uma oportunidade comercial, com valor do deal, valor ganho, status de ganho/perda, dias para fechamento e chaves para empresa, plano, etapa e datas.
- `fact_subscriptions`: fato de assinaturas em nivel de subscription. Cada linha representa uma assinatura, com MRR, ARR, churned MRR, tempo de vida, LTV e chaves para empresa, plano e datas de inicio, fim e cohort.
- `fact_mrr_monthly`: fato de movimentos de receita recorrente por mes. Cada linha representa um movimento de MRR classificado como `New`, `Expansion`, `Contraction` ou `Churned`, com granularidade mensal e chaves para empresa e plano.
- `fact_funnel_conversion`: fato de conversao entre etapas do funil. Cada linha representa a performance de transicao entre uma etapa e a seguinte, com deals que entraram, deals que avancaram, percentual de conversao e chaves de etapa, empresa, plano e data.

### Dimensions

- `dim_companies`: dimensao de empresas clientes e prospects. Centraliza atributos descritivos como nome da empresa, segmento, industria, porte, cidade, estado e data de criacao.
- `dim_plans`: dimensao de planos comerciais. Centraliza nome do plano, valor de referencia de MRR, tier e flag de enterprise.
- `dim_stages`: dimensao de etapas do funil comercial. Define a ordem das etapas e os indicadores semanticos de etapa fechada, ganha ou perdida.
- `dim_dates`: dimensao calendario. Centraliza data completa, ano, trimestre, mes, nome do mes, semana e atributos temporais para analise.

## Como Ler o Modelo

Para continuidade em outros chats ou handoffs, este e o entendimento base do modelo:

- `fact_deals` responde perguntas de pipeline, win rate, ticket medio e ciclo de vendas
- `fact_subscriptions` responde perguntas de base ativa, churn, retention, LTV e cohort
- `fact_mrr_monthly` responde perguntas de evolucao de receita e movimentos de MRR
- `fact_funnel_conversion` responde perguntas de conversao entre etapas do funil
- `dim_companies`, `dim_plans`, `dim_stages` e `dim_dates` sao as tabelas de filtro e contextualizacao do modelo

## Relacoes Recomendadas

Relacoes principais para o modelo semantico:

- `fact_deals[company_key]` -> `dim_companies[company_key]`
- `fact_deals[plan_key]` -> `dim_plans[plan_key]`
- `fact_deals[stage_key]` -> `dim_stages[stage_key]`
- `fact_deals[created_date_key]` -> `dim_dates[date_key]`
- `fact_subscriptions[company_key]` -> `dim_companies[company_key]`
- `fact_subscriptions[plan_key]` -> `dim_plans[plan_key]`
- `fact_subscriptions[start_date_key]` -> `dim_dates[date_key]`
- `fact_mrr_monthly[company_key]` -> `dim_companies[company_key]`
- `fact_mrr_monthly[plan_key]` -> `dim_plans[plan_key]`

Relacoes com cuidado especial:

- `fact_funnel_conversion[from_stage_key]` -> `dim_stages[stage_key]`
- `fact_funnel_conversion[to_stage_key]` -> `dim_stages[stage_key]`

No Power BI, essa tabela tem duas chaves para a mesma dimensao. O mais seguro para a primeira versao e:

- manter uma relacao ativa para `from_stage_key`
- deixar `to_stage_key` sem relacao ativa ou tratar com segunda dimensao de stages se necessario

Tambem havera multiplas datas em algumas facts. Para a primeira versao do dashboard, recomendo:

- usar `created_date_key` como data principal de `fact_deals`
- usar `start_date_key` como data principal de `fact_subscriptions`
- tratar datas alternativas como relacoes inativas apenas quando houver necessidade analitica

## Passo a Passo no Power BI Desktop

1. Abrir o Power BI Desktop.
2. Ir em `Get data`.
3. Selecionar `Google BigQuery`.
4. Escolher autenticacao por conta organizacional ou service account.
5. Informar o projeto de billing se o conector solicitar.
6. Navegar ate `revops-analytics-personal > revops`.
7. Selecionar as tabelas recomendadas.
8. Clicar em `Load` para carga direta ou `Transform Data` se quiser ajustar nomes e tipos.
9. No Model view, criar as relacoes recomendadas deste documento.
10. Salvar o arquivo `.pbix` como camada de consumo analitico oficial do projeto.

## Observacao sobre o Conector

O conector de Google BigQuery no ecossistema Microsoft esta em disponibilidade geral, mas a Microsoft tambem disponibilizou uma nova implementacao em preview baseada em ADBC.

Para este projeto, a recomendacao inicial e simples:

- usar a versao estavel padrao do conector na primeira conexao
- avaliar a nova implementacao depois, caso haja ganho claro de performance

Isso reduz risco durante a modelagem inicial do dashboard.

## Recomendacao de Conexao

Para este projeto, a recomendacao inicial e:

- usar Import para a primeira versao do dashboard
- deixar DirectQuery para uma iteracao futura, se houver necessidade especifica

Motivo:

- o volume deste projeto e pequeno
- a experiencia de modelagem e medidas fica mais simples
- a primeira versao do portfolio fica mais estavel para demonstracao

## Paginas Recomendadas do Dashboard

Estrutura inicial sugerida:

- Funnel: volume de deals por etapa, taxa de conversao, win rate, tempo medio de fechamento
- Revenue: MRR ativo, ARR, new MRR, expansion, contraction, churned MRR
- Churn e Retention: churn rate, churned MRR, tempo medio de vida, distribuicao por plano e segmento

## Checklist Antes de Conectar

Antes de abrir o Power BI, confirmar:

- DAG `revops_analytics_daily` executando com sucesso
- `dbt run` e `dbt test` sem falhas
- dataset `revops` atualizado no BigQuery
- credenciais com acesso de leitura ao BigQuery

## Proximo Passo

Depois da conexao, o passo mais coerente e definir o modelo semantico final do dashboard e listar as medidas DAX principais de cada pagina.
