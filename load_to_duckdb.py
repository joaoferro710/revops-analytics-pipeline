import duckdb
import pandas as pd
import os

# ── Conexão com o banco ───────────────────────────────────────────
os.makedirs('data/db', exist_ok=True)
con = duckdb.connect('data/db/revops.duckdb')

# ── Carregar CSVs ─────────────────────────────────────────────────
tables = {
    'raw_companies':     'data/raw/companies.csv',
    'raw_contacts':      'data/raw/contacts.csv',
    'raw_deals':         'data/raw/deals.csv',
    'raw_subscriptions': 'data/raw/subscriptions.csv',
    'raw_activities':    'data/raw/activities.csv',
}

print("Carregando tabelas no DuckDB...\n")
for table_name, csv_path in tables.items():
    con.execute(f"""
        CREATE OR REPLACE TABLE {table_name} AS
        SELECT * FROM read_csv_auto('{csv_path}')
    """)
    count = con.execute(f"SELECT COUNT(*) FROM {table_name}").fetchone()[0]
    print(f"  ✅ {table_name}: {count:,} registros")

# ── Validação rápida ──────────────────────────────────────────────
print("\n── Validação: deals por stage ──────────────────────────")
result = con.execute("""
    SELECT stage, COUNT(*) as total, SUM(amount) as receita_total
    FROM raw_deals
    GROUP BY stage
    ORDER BY total DESC
""").df()
print(result.to_string(index=False))

print("\n── Validação: MRR ativo por plano ──────────────────────")
result = con.execute("""
    SELECT plan, COUNT(*) as clientes, SUM(mrr) as mrr_total
    FROM raw_subscriptions
    WHERE status = 'Active'
    GROUP BY plan
    ORDER BY mrr_total DESC
""").df()
print(result.to_string(index=False))

con.close()
print("\n✅ DuckDB carregado com sucesso em data/db/revops.duckdb")