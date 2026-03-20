import pandas as pd

# ── Carregar dados ────────────────────────────────────────────────
companies     = pd.read_csv('data/raw/companies.csv')
contacts      = pd.read_csv('data/raw/contacts.csv')
deals         = pd.read_csv('data/raw/deals.csv')
subscriptions = pd.read_csv('data/raw/subscriptions.csv')
activities    = pd.read_csv('data/raw/activities.csv')

datasets = {
    'companies':     companies,
    'contacts':      contacts,
    'deals':         deals,
    'subscriptions': subscriptions,
    'activities':    activities,
}

# ── Visão geral ───────────────────────────────────────────────────
print("=" * 55)
print("VISÃO GERAL DOS DATASETS")
print("=" * 55)
for name, df in datasets.items():
    print(f"\n📄 {name.upper()}")
    print(f"   Linhas: {len(df):,} | Colunas: {df.shape[1]}")
    print(f"   Colunas: {list(df.columns)}")

# ── Deals por stage ───────────────────────────────────────────────
print("\n" + "=" * 55)
print("DEALS POR STAGE")
print("=" * 55)
stage_summary = (
    deals.groupby('stage')
    .agg(total=('deal_id', 'count'), valor_total=('amount', 'sum'))
    .sort_values('total', ascending=False)
)
stage_summary['valor_total'] = stage_summary['valor_total'].apply(lambda x: f"R$ {x:,.0f}")
print(stage_summary.to_string())

# ── Conversão do funil ────────────────────────────────────────────
print("\n" + "=" * 55)
print("TAXA DE CONVERSÃO DO FUNIL")
print("=" * 55)
total_deals = len(deals)
won         = len(deals[deals['stage'] == 'Closed Won'])
lost        = len(deals[deals['stage'] == 'Closed Lost'])
print(f"   Total de deals:   {total_deals}")
print(f"   Closed Won:       {won} ({won/total_deals*100:.1f}%)")
print(f"   Closed Lost:      {lost} ({lost/total_deals*100:.1f}%)")
print(f"   Em andamento:     {total_deals - won - lost}")

# ── MRR atual ────────────────────────────────────────────────────
print("\n" + "=" * 55)
print("MRR POR PLANO")
print("=" * 55)
mrr_summary = (
    subscriptions[subscriptions['status'] == 'Active']
    .groupby('plan')
    .agg(clientes=('subscription_id', 'count'), mrr_total=('mrr', 'sum'))
    .sort_values('mrr_total', ascending=False)
)
mrr_summary['mrr_total'] = mrr_summary['mrr_total'].apply(lambda x: f"R$ {x:,.0f}")
print(mrr_summary.to_string())

# ── Churn ─────────────────────────────────────────────────────────
print("\n" + "=" * 55)
print("CHURN")
print("=" * 55)
total_subs  = len(subscriptions)
churned     = len(subscriptions[subscriptions['status'] == 'Churned'])
active      = len(subscriptions[subscriptions['status'] == 'Active'])
print(f"   Total de assinaturas: {total_subs}")
print(f"   Ativas:               {active} ({active/total_subs*100:.1f}%)")
print(f"   Churned:              {churned} ({churned/total_subs*100:.1f}%)")

# ── Segmento das empresas ─────────────────────────────────────────
print("\n" + "=" * 55)
print("EMPRESAS POR SEGMENTO")
print("=" * 55)
print(companies['segment'].value_counts().to_string())

print("\n✅ Sanity check concluído!")

