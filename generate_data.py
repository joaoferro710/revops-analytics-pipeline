import pandas as pd
import numpy as np
from faker import Faker
from datetime import timedelta
import random
import os

fake = Faker('pt_BR')
random.seed(42)
np.random.seed(42)

N_COMPANIES     = 300
N_DEALS         = 600
START_DATE      = pd.Timestamp('2022-01-01')
END_DATE        = pd.Timestamp('2024-12-31')

SEGMENTS        = ['SMB', 'Mid-Market', 'Enterprise']
SEGMENTS_WEIGHT = [0.6, 0.3, 0.1]

PLANS           = ['Starter', 'Growth', 'Pro', 'Enterprise']
PLAN_MRR        = {'Starter': 199, 'Growth': 599, 'Pro': 1499, 'Enterprise': 3999}
PLAN_ORDER      = {'Starter': 1, 'Growth': 2, 'Pro': 3, 'Enterprise': 4}

DEAL_STAGES     = ['Prospecting', 'Qualified', 'Proposal', 'Negotiation', 'Closed Won', 'Closed Lost']
STAGE_SEQUENCE  = ['Prospecting', 'Qualified', 'Proposal', 'Negotiation', 'Closed Won']


def random_date(start, end):
    delta = (end - start).days
    if delta <= 0:
        return start
    return start + timedelta(days=random.randint(0, delta))


def generate_companies():
    rows = []
    for i in range(N_COMPANIES):
        segment = random.choices(SEGMENTS, SEGMENTS_WEIGHT)[0]
        rows.append({
            'company_id':   f'COMP-{i+1:04d}',
            'name':         fake.company(),
            'segment':      segment,
            'industry':     random.choice(['SaaS', 'Fintech', 'E-commerce', 'Healthtech', 'Edtech']),
            'employees':    random.randint(10, 5000),
            'city':         fake.city(),
            'state':        fake.estado_sigla(),
            'created_at':   random_date(START_DATE, END_DATE),
        })
    return pd.DataFrame(rows)


def generate_contacts(companies):
    rows = []
    contact_id = 1
    for _, company in companies.iterrows():
        n = random.randint(2, 5)
        for _ in range(n):
            rows.append({
                'contact_id':   f'CONT-{contact_id:04d}',
                'company_id':   company['company_id'],
                'name':         fake.name(),
                'email':        fake.email(),
                'role':         random.choice(['CEO', 'CFO', 'VP Sales', 'Head of Marketing', 'Operations Manager']),
                'created_at':   company['created_at'] + timedelta(days=random.randint(0, 30)),
            })
            contact_id += 1
    return pd.DataFrame(rows)


def generate_deals(companies):
    rows = []
    for i in range(N_DEALS):
        company    = companies.sample(1).iloc[0]
        stage      = random.choices(
            DEAL_STAGES,
            weights=[0.1, 0.15, 0.2, 0.15, 0.25, 0.15]
        )[0]
        created_at = random_date(START_DATE, END_DATE)
        closed_at  = created_at + timedelta(days=random.randint(7, 180)) \
                     if stage in ['Closed Won', 'Closed Lost'] else None
        plan       = random.choice(PLANS)
        rows.append({
            'deal_id':    f'DEAL-{i+1:04d}',
            'company_id': company['company_id'],
            'plan':       plan,
            'stage':      stage,
            'amount':     PLAN_MRR[plan] * random.randint(1, 24),
            'created_at': created_at,
            'closed_at':  closed_at,
        })
    return pd.DataFrame(rows)


def generate_subscriptions(deals):
    won  = deals[deals['stage'] == 'Closed Won'].copy()
    rows = []
    for _, deal in won.iterrows():
        plan       = deal['plan']
        start_date = deal['closed_at']
        churned    = random.random() < 0.25
        end_date   = start_date + timedelta(days=random.randint(90, 730)) if churned else None
        rows.append({
            'subscription_id': f'SUB-{deal["deal_id"]}',
            'company_id':      deal['company_id'],
            'deal_id':         deal['deal_id'],
            'plan':            plan,
            'mrr':             PLAN_MRR[plan],
            'status':          'Churned' if churned else 'Active',
            'start_date':      start_date,
            'end_date':        end_date,
        })
    return pd.DataFrame(rows)


def generate_plan_changes(subscriptions):
    rows = []
    change_id = 1
    active_subs = subscriptions[subscriptions['status'] == 'Active'].copy()

    for _, sub in active_subs.iterrows():
        if random.random() > 0.30:
            continue

        current_plan  = sub['plan']
        current_order = PLAN_ORDER[current_plan]

        upgrade_possible   = [p for p, o in PLAN_ORDER.items() if o > current_order]
        downgrade_possible = [p for p, o in PLAN_ORDER.items() if o < current_order]

        if not upgrade_possible and not downgrade_possible:
            continue

        is_upgrade = random.random() < 0.75
        if is_upgrade and upgrade_possible:
            new_plan = random.choice(upgrade_possible)
        elif downgrade_possible:
            new_plan = random.choice(downgrade_possible)
        else:
            new_plan = random.choice(upgrade_possible)

        change_date = sub['start_date'] + timedelta(days=random.randint(90, 365))
        if change_date > END_DATE:
            change_date = END_DATE - timedelta(days=random.randint(1, 30))

        rows.append({
            'change_id':        f'CHG-{change_id:04d}',
            'subscription_id':  sub['subscription_id'],
            'company_id':       sub['company_id'],
            'from_plan':        current_plan,
            'to_plan':          new_plan,
            'from_mrr':         PLAN_MRR[current_plan],
            'to_mrr':           PLAN_MRR[new_plan],
            'mrr_delta':        PLAN_MRR[new_plan] - PLAN_MRR[current_plan],
            'change_type':      'Upgrade' if PLAN_ORDER[new_plan] > current_order else 'Downgrade',
            'change_date':      change_date,
        })
        change_id += 1

    return pd.DataFrame(rows)


def generate_activities(contacts, deals):
    rows = []
    activity_id = 1
    for _, deal in deals.iterrows():
        n             = random.randint(2, 10)
        deal_contacts = contacts[contacts['company_id'] == deal['company_id']]
        if deal_contacts.empty:
            continue
        for _ in range(n):
            contact = deal_contacts.sample(1).iloc[0]
            rows.append({
                'activity_id': f'ACT-{activity_id:04d}',
                'deal_id':     deal['deal_id'],
                'contact_id':  contact['contact_id'],
                'type':        random.choice(['Email', 'Call', 'Meeting', 'Demo', 'Proposal Sent']),
                'outcome':     random.choice(['Positive', 'Neutral', 'Negative']),
                'date':        random_date(deal['created_at'], END_DATE),
            })
            activity_id += 1
    return pd.DataFrame(rows)


def generate_stage_history(deals):
    rows = []
    for _, deal in deals.iterrows():
        current_stage = deal['stage']

        if current_stage == 'Closed Lost':
            lost_at       = random.randint(1, 4)
            stages_passed = STAGE_SEQUENCE[:lost_at] + ['Closed Lost']
        elif current_stage == 'Closed Won':
            stages_passed = STAGE_SEQUENCE
        else:
            idx           = STAGE_SEQUENCE.index(current_stage)
            stages_passed = STAGE_SEQUENCE[:idx + 1]

        entry_date = deal['created_at']
        for stage in stages_passed:
            rows.append({
                'deal_id':    deal['deal_id'],
                'stage':      stage,
                'entered_at': entry_date,
            })
            entry_date = entry_date + timedelta(days=random.randint(5, 45))

    return pd.DataFrame(rows)


if __name__ == '__main__':
    os.makedirs('data/raw', exist_ok=True)

    print("Gerando companies...")
    companies = generate_companies()
    companies.to_csv('data/raw/companies.csv', index=False)

    print("Gerando contacts...")
    contacts = generate_contacts(companies)
    contacts.to_csv('data/raw/contacts.csv', index=False)

    print("Gerando deals...")
    deals = generate_deals(companies)
    deals.to_csv('data/raw/deals.csv', index=False)

    print("Gerando subscriptions...")
    subscriptions = generate_subscriptions(deals)
    subscriptions.to_csv('data/raw/subscriptions.csv', index=False)

    print("Gerando plan changes...")
    plan_changes = generate_plan_changes(subscriptions)
    plan_changes.to_csv('data/raw/plan_changes.csv', index=False)

    print("Gerando activities...")
    activities = generate_activities(contacts, deals)
    activities.to_csv('data/raw/activities.csv', index=False)

    print("Gerando stage history...")
    stage_history = generate_stage_history(deals)
    stage_history.to_csv('data/raw/stage_history.csv', index=False)

    print("\n✅ Dados gerados com sucesso!")
    print(f"  companies:     {len(companies)} registros")
    print(f"  contacts:      {len(contacts)} registros")
    print(f"  deals:         {len(deals)} registros")
    print(f"  subscriptions: {len(subscriptions)} registros")
    print(f"  plan_changes:  {len(plan_changes)} registros")
    print(f"  activities:    {len(activities)} registros")
    print(f"  stage_history: {len(stage_history)} registros")