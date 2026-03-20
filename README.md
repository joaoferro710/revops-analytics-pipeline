# RevOps Analytics Pipeline 🚀

Pipeline de dados end-to-end focado em métricas de Revenue Operations (RevOps) para empresas SaaS B2B.

## Sobre o projeto

Este projeto simula o ambiente de dados de uma empresa SaaS B2B, cobrindo as principais métricas de RevOps:

- **Funil de vendas** — conversão por stage, velocity e win rate
- **Churn e retenção** — análise de cancelamentos e saúde da base
- **Forecasting de receita** — projeção de MRR e ARR

## Arquitetura
```
Geração de dados sintéticos (Python)
        ↓
Armazenamento local (CSV → DuckDB)
        ↓
Transformações (dbt)
        ↓
Orquestração (Airflow)
        ↓
Dashboard (Streamlit)
```

## Stack

- **Python 3.14** — geração e processamento de dados
- **DuckDB** — armazenamento analítico local
- **dbt** — transformações e modelagem
- **Airflow** — orquestração do pipeline
- **Streamlit** — visualização

## Como executar
```bash
# Clone o repositório
git clone https://github.com/seu-usuario/revops-analytics-pipeline.git
cd revops-analytics-pipeline

# Crie e ative o ambiente virtual
py -m venv .venv
.venv\Scripts\activate

# Instale as dependências
pip install -r requirements.txt

# Gere os dados sintéticos
py generate_data.py
```

## Autor

João Ferro — [LinkedIn](#) | [GitHub](#)