# RevOps Analytics Pipeline

Projeto end-to-end de dados para uma empresa SaaS B2B fictícia, cobrindo geração de dados, ingestão em BigQuery, modelagem analítica com dbt, orquestração com Airflow e consumo no Power BI.

O objetivo deste repositório é simular um fluxo de dados próximo de um cenário corporativo real de Revenue Operations, com foco em funil comercial, receita recorrente, churn, retenção e cohort analysis.

## Sumário

1. [Visão geral](#visão-geral)
2. [Arquitetura](#arquitetura)
3. [Contexto de negócio](#contexto-de-negócio)
4. [Stack utilizada](#stack-utilizada)
5. [Estrutura do repositório](#estrutura-do-repositório)
6. [Dados gerados no projeto](#dados-gerados-no-projeto)
7. [Pipeline orquestrado](#pipeline-orquestrado)
8. [Camadas analíticas no dbt](#camadas-analíticas-no-dbt)
9. [Qualidade de dados](#qualidade-de-dados)
10. [Power BI](#power-bi)
11. [Resultados obtidos](#resultados-obtidos)
12. [Como executar](#como-executar)
13. [Aprendizados e próximos passos](#aprendizados-e-próximos-passos)

## Visão geral

O pipeline foi construído para responder perguntas típicas de RevOps:

- Quantos deals entraram e avançaram em cada etapa do funil
- Qual é a taxa de win rate por segmento, plano e período
- Qual é o MRR ativo, ARR, churned MRR, expansion e contraction
- Como está a retenção de clientes ao longo do tempo
- Quais cohorts retêm melhor e em que momento começam a deteriorar

O projeto elimina etapas analíticas paralelas fora da stack principal. A camada final consumida pelo Power BI vem diretamente do BigQuery.

## Arquitetura

```text
Python synthetic source
        |
generate_data.py
        |
load_to_bigquery.py
        |
BigQuery raw (revops_raw)
        |
dbt run
        |
dbt test
        |
BigQuery analytics (revops)
        |
Power BI
```

Execução diária no Airflow:

```text
generate_raw_data
    -> load_raw_to_bigquery
    -> dbt_run_bigquery
    -> dbt_test_bigquery
```

## Contexto de negócio

A empresa fictícia opera com modelo SaaS B2B, vendendo quatro planos:

- Starter
- Growth
- Pro
- Enterprise

Os dados simulam o ciclo completo de aquisição e retenção:

- empresas
- contatos
- deals
- histórico de estágio
- atividades comerciais
- assinaturas
- mudanças de plano

Isso permite construir uma visão integrada entre pipeline comercial, conversão, base ativa, receita recorrente e churn.

## Stack utilizada

- Python 3.12
- Pandas
- Faker
- Google BigQuery
- dbt Core 1.11
- Apache Airflow 3
- Docker Compose
- Power BI

## Estrutura do repositório

```text
revops-analytics-pipeline/
+-- airflow/
|   +-- dags/
|   |   +-- revops_pipeline_dag.py
|   +-- docker-compose.yml
|   +-- Dockerfile
|   +-- requirements.txt
+-- credentials/
+-- data/
|   +-- raw/
+-- logs/
+-- powerbi/
|   +-- powerbi_bigquery_setup.md
+-- revops_dbt/
|   +-- models/
|   |   +-- staging/
|   |   +-- marts/
|   +-- profiles/
|   +-- tests/
|   +-- dbt_project.yml
|   +-- target/
+-- explore_data.py
+-- generate_data.py
+-- load_to_bigquery.py
+-- requirements.txt
+-- README.md
```

## Dados gerados no projeto

Os dados são sintéticos, mas seguem regras de negócio coerentes com um cenário SaaS.

### Volumetria atual da base

- 300 empresas
- 1.041 contatos
- 600 deals
- 155 assinaturas
- 38 mudanças de plano
- 3.497 atividades
- 2.030 eventos de stage history

### Janela temporal

- deals gerados entre 2022-01-01 e 2024-12-31
- assinaturas iniciadas entre 2022-01-22 e 2025-05-21
- 38 cohorts mensais identificáveis na base

### Regras de geração implementadas

- distribuição de segmentos com maior peso para SMB
- planos com MRR fixo por tier
- estágios comerciais com distribuição probabilística
- assinatura criada apenas a partir de deals Closed Won
- churn aplicado sobre parte da base com duração variável
- mudança de plano apenas sobre assinaturas ativas
- upgrades mais frequentes que downgrades
- histórico de passagem por etapas comerciais
- atividades comerciais ligadas a deals e contatos

## Pipeline orquestrado

A DAG principal está em [airflow/dags/revops_pipeline_dag.py](/c:/Users/Felipe/revops-analytics-pipeline/airflow/dags/revops_pipeline_dag.py).

Características implementadas:

- execução diária às 06:00 UTC
- `catchup=False`
- `max_active_runs=1`
- `retries=2`
- `retry_delay=5 minutes`
- execução de Python e dbt dentro da stack do Airflow

### Ordem das tarefas

1. `generate_raw_data`
2. `load_raw_to_bigquery`
3. `dbt_run_bigquery`
4. `dbt_test_bigquery`

### Infraestrutura Airflow

A stack local usa:

- `postgres`
- `airflow-init`
- `airflow-api-server`
- `airflow-scheduler`
- `airflow-dag-processor`

O ambiente foi ajustado para o padrão do Airflow 3, incluindo `api-server` e `dag-processor`.

## Camadas analíticas no dbt

O projeto dbt está em [revops_dbt](/c:/Users/Felipe/revops-analytics-pipeline/revops_dbt).

### Sources

As fontes são lidas do dataset `revops_raw`:

- `companies`
- `contacts`
- `deals`
- `subscriptions`
- `plan_changes`
- `activities`
- `stage_history`

### Staging

Modelos de padronização:

- `stg_companies`
- `stg_contacts`
- `stg_deals`
- `stg_subscriptions`
- `stg_plan_changes`
- `stg_activities`
- `stg_stage_history`

Esses modelos tratam tipos, nomes de campos e flags analíticas como `is_closed`, `is_won` e `is_churned`.

### Dimensions

Dimensões publicadas:

- `dim_companies`
- `dim_plans`
- `dim_stages`
- `dim_dates`

Exemplos de enriquecimento:

- classificação de porte da empresa em `Micro`, `Small`, `Medium` e `Large`
- tier dos planos e flag `is_enterprise`
- calendário com `date_key`, `year_month`, quarter, weekday e atributos auxiliares

### Facts

Fatos modelados:

- `fact_deals`
- `fact_subscriptions`
- `fact_mrr_monthly`
- `fact_funnel_conversion`

Essas tabelas sustentam um modelo semântico mais próximo de um ambiente de BI corporativo.

### Marts analíticos

Tabelas de consumo rápido:

- `mart_funnel`
- `mart_churn`
- `mart_mrr`
- `mart_funnel_conversion`

Essas marts aceleram a prototipação de dashboards e análises exploratórias.

## Qualidade de dados

O projeto possui validação automatizada em múltiplas camadas:

- `not_null`
- `unique`
- `relationships`
- `accepted_values`
- testes de regra de negócio customizados

Exemplos de regras customizadas:

- assinaturas ativas não devem ter `end_date`
- assinaturas churned devem ter `end_date`
- deals fechados devem ter `closed_at`
- `won_amount` deve refletir corretamente a flag de ganho

### Resultado validado

Em uma execução completa do pipeline:

- `dbt run`: `PASS=19`
- `dbt test`: `PASS=138`
- `WARN=0`
- `ERROR=0`

Artefatos gerados no dbt indicam:

- 19 modelos
- 138 testes
- 7 sources

## Power BI

O consumo analítico foi desenhado para acontecer diretamente sobre o dataset `revops` no BigQuery.

Guia técnico de conexão e modelagem:

- [powerbi/powerbi_bigquery_setup.md](/c:/Users/Felipe/revops-analytics-pipeline/powerbi/powerbi_bigquery_setup.md)

### Estrutura analítica prevista no dashboard

O dashboard foi organizado em torno de quatro frentes principais:

- Funnel
- Revenue
- Churn / Retention
- Cohort Analysis

### Modelo semântico recomendado

Tabelas recomendadas no Power BI:

- `fact_deals`
- `fact_subscriptions`
- `fact_mrr_monthly`
- `fact_funnel_conversion`
- `dim_companies`
- `dim_plans`
- `dim_stages`
- `dim_dates`

### Observação sobre cohort analysis

Para análise de cohort no Power BI, o caminho mais estável foi usar:

- linhas por `cohort_label`
- colunas por mês relativo (`M0`, `M1`, `M2`...)
- tabela desconectada de offsets para retenção

Esse desenho evita conflito entre o mês de aquisição e o mês de retenção quando a fato usa `start_date_key` como relação de data principal.

## Screenshots do dashboard

### Funnel

![Funnel](powerbi/screenshots/funnel.png)

### Revenue

![Revenue](powerbi/screenshots/revenue.png)

### Churn & Retention

![Churn & Retention](powerbi/screenshots/churn-retention.png)

### Cohort Analysis

![Cohort Analysis](powerbi/screenshots/cohort-analysis.png)

### Modelo semântico

![Schema](powerbi/screenshots/schema.png)

### Medidas DAX

![Measures](powerbi/screenshots/measures.png)

## Resultados obtidos

### Engenharia

- geração de dados funcionando localmente e via Airflow
- carga raw funcionando no BigQuery com `WRITE_TRUNCATE`
- dbt executando dentro do ambiente orquestrado
- testes de qualidade executando no mesmo fluxo da DAG
- camada analítica final publicada no dataset `revops`

### Retrato da empresa fictícia

#### Pipeline comercial

- 600 deals no total
- 155 `Closed Won`
- 85 `Closed Lost`
- 360 deals ainda em aberto
- win rate geral sobre o total: `25,83%`
- win rate sobre deals fechados: `64,58%`
- ticket médio geral: `21.063,42`
- ticket médio de deals ganhos: `23.847,41`
- ciclo médio de venda dos deals fechados: `94,92 dias`

#### Receita e base ativa

- 155 assinaturas geradas a partir de deals ganhos
- 114 assinaturas ativas
- 41 assinaturas churned
- churn de assinaturas: `26,45%`
- MRR total histórico da base: `265.745`
- MRR ativo atual: `200.886`
- ARR estimado atual: `2.410.632`
- churned MRR acumulado na base: `64.859`

#### Mix de planos

- Enterprise: 46 assinaturas
- Starter: 42 assinaturas
- Pro: 37 assinaturas
- Growth: 30 assinaturas

Na base ativa, o plano Enterprise concentra `71,66%` do MRR atual, o que mostra alta dependência de contas de maior ticket.

#### Mudanças de plano

- 38 mudanças de plano
- 30 upgrades
- 8 downgrades
- `78,95%` das mudanças são upgrades
- delta líquido de MRR em plan changes: `+33.800`

Esse comportamento sugere uma operação com bom potencial de expansão dentro da base, apesar da pressão de churn em parte dos clientes.

## Como executar

### 1. Pré-requisitos

- Python 3.12
- Docker Desktop
- acesso a um projeto no GCP com BigQuery habilitado
- credencial de service account com permissão de leitura e escrita nos datasets

### 2. Clonar o repositório

```bash
git clone https://github.com/seu-usuario/revops-analytics-pipeline.git
cd revops-analytics-pipeline
```

### 3. Criar ambiente virtual local

```bash
py -3.12 -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

### 4. Gerar dados locais

```bash
py generate_data.py
```

Arquivos gerados em `data/raw/`:

- `companies.csv`
- `contacts.csv`
- `deals.csv`
- `subscriptions.csv`
- `plan_changes.csv`
- `activities.csv`
- `stage_history.csv`

### 5. Configurar credenciais e variáveis

Variáveis relevantes:

- `GCP_PROJECT_ID`
- `BQ_RAW_DATASET_ID`
- `BQ_ANALYTICS_DATASET_ID`
- `BQ_LOCATION`
- `GOOGLE_APPLICATION_CREDENTIALS`
- `DBT_PROFILES_DIR`

O diretório `credentials/` é local e deve permanecer fora do versionamento.

### 6. Carregar dados no BigQuery

```bash
py load_to_bigquery.py
```

O script:

- garante a existência do dataset raw
- lê os CSVs de `data/raw`
- carrega cada tabela com `WRITE_TRUNCATE`

### 7. Executar o dbt localmente

```bash
cd revops_dbt
dbt run --target bigquery --profiles-dir profiles
dbt test --target bigquery --profiles-dir profiles
```

### 8. Subir o Airflow local

```bash
cd airflow
copy .env.example .env
docker compose up -d
```

Depois disso:

- Airflow disponível em `http://localhost:8080`
- DAG principal: `revops_analytics_daily`
- autenticação local padrão: `admin / admin`

### 9. Conectar o Power BI

1. Abrir o Power BI Desktop
2. Selecionar `Get data`
3. Conectar em `Google BigQuery`
4. Navegar até `revops-analytics-personal > revops`
5. Importar as facts e dimensions recomendadas
6. Criar as relações descritas no guia em `powerbi/powerbi_bigquery_setup.md`

## Aprendizados e próximos passos

Este projeto consolidou uma base sólida de:

- modelagem analítica para RevOps
- integração entre orquestração, transformação e BI
- desenho de facts e dimensions para consumo semântico
- testes de qualidade dentro do fluxo de entrega de dados

Evoluções naturais para uma próxima iteração:

- publicar capturas do dashboard no repositório
- adicionar CI para validação automática de dbt
- separar credenciais e configurações sensíveis por ambiente
- incluir monitoramento e alertas operacionais
- ampliar a modelagem para NRR, GRR e forecasting

## Observações importantes

- Há logs de tentativas antigas do Airflow durante a fase de configuração inicial. As execuções mais recentes do pipeline estão consistentes e concluídas com sucesso.
- O repositório possui um diretório `models/` legado fora do projeto dbt principal. A modelagem ativa usada no pipeline está em `revops_dbt/models/`.
