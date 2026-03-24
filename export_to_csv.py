import duckdb
import os

os.makedirs('data/marts', exist_ok=True)

con = duckdb.connect('data/db/revops.duckdb', read_only=True)

marts = [
    'fact_deals',
    'fact_funnel_conversion',
    'fact_subscriptions',
    'fact_mrr_monthly',
    'dim_companies',
    'dim_plans',
    'dim_stages',
    'dim_dates',
]

print("Exportando marts para CSV...\n")
for mart in marts:
    df = con.execute(f"SELECT * FROM main.{mart}").df()
    path = f'data/marts/{mart}.csv'
    df.to_csv(path, index=False)
    print(f"  ✅ {mart}: {len(df):,} registros → {path}")

con.close()
print("\n✅ Exportação concluída!")