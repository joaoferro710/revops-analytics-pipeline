from __future__ import annotations

import os
from datetime import datetime, timedelta

from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator

REPO_DIR = os.getenv("REVOPS_REPO_DIR", "/opt/revops")
DBT_PROJECT_DIR = f"{REPO_DIR}/revops_dbt"
DBT_PROFILES_DIR = os.getenv("DBT_PROFILES_DIR", f"{DBT_PROJECT_DIR}/profiles")
PYTHON_BIN = os.getenv("REVOPS_PYTHON_BIN", "python")
DBT_BIN = os.getenv("REVOPS_DBT_BIN", "dbt")

default_args = {
    "owner": "data-platform",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="revops_analytics_daily",
    description="Pipeline diario de RevOps: fonte simulada, raw no BigQuery e transformacoes dbt.",
    default_args=default_args,
    start_date=datetime(2026, 3, 30),
    schedule="0 6 * * *",
    catchup=False,
    max_active_runs=1,
    tags=["revops", "bigquery", "dbt"],
) as dag:
    generate_raw_data = BashOperator(
        task_id="generate_raw_data",
        bash_command=f"cd {REPO_DIR} && {PYTHON_BIN} generate_data.py",
    )

    load_raw_to_bigquery = BashOperator(
        task_id="load_raw_to_bigquery",
        bash_command=f"cd {REPO_DIR} && {PYTHON_BIN} load_to_bigquery.py",
    )

    dbt_run_bigquery = BashOperator(
        task_id="dbt_run_bigquery",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            f"{DBT_BIN} run --target bigquery --profiles-dir {DBT_PROFILES_DIR}"
        ),
    )

    dbt_test_bigquery = BashOperator(
        task_id="dbt_test_bigquery",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            f"{DBT_BIN} test --target bigquery --profiles-dir {DBT_PROFILES_DIR}"
        ),
    )

    generate_raw_data >> load_raw_to_bigquery >> dbt_run_bigquery >> dbt_test_bigquery
