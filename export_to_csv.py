import duckdb
import os

os.makedirs('data/marts', exist_ok=True)

con = duckdb.connect('data/db/revops.duckdb', read_only=True)

marts = ['mart_funnel', 'mart_churn', 'mart_mrr', 'mart_funnel_conversion']

print("Exportando marts para CSV...\n")
for mart in marts:
    df = con.execute(f"SELECT * FROM main.{mart}").df()
    path = f'data/marts/{mart}.csv'
    df.to_csv(path, index=False)
    print(f"  ✅ {mart}: {len(df):,} registros → {path}")

con.close()
print("\n✅ Exportação concluída!")