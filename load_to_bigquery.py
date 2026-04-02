import os
from pathlib import Path
import logging

import pandas as pd
from google.cloud import bigquery
from google.oauth2 import service_account

logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format="%(asctime)s | %(levelname)s | %(message)s",
)
logger = logging.getLogger(__name__)

PROJECT_ID = os.getenv("GCP_PROJECT_ID", "revops-analytics-personal")
DATASET_ID = os.getenv("BQ_RAW_DATASET_ID", "revops_raw")
DATASET_LOCATION = os.getenv("BQ_LOCATION", "US")
WORKDIR = Path(__file__).resolve().parent
CREDENTIALS_PATH = Path(
    os.getenv(
        "GOOGLE_APPLICATION_CREDENTIALS",
        WORKDIR / "credentials" / "revops-analytics-personal-a1021129b620.json",
    )
)
RAW_DATA_PATH = Path(os.getenv("RAW_DATA_PATH", WORKDIR / "data" / "raw"))

TABLES = [
    "companies",
    "contacts",
    "deals",
    "subscriptions",
    "plan_changes",
    "activities",
    "stage_history",
]


def get_bigquery_client() -> bigquery.Client:
    if not CREDENTIALS_PATH.exists():
        raise FileNotFoundError(
            f"Arquivo de credenciais nao encontrado em: {CREDENTIALS_PATH}"
        )

    credentials = service_account.Credentials.from_service_account_file(
        str(CREDENTIALS_PATH),
        scopes=["https://www.googleapis.com/auth/cloud-platform"],
    )
    return bigquery.Client(project=PROJECT_ID, credentials=credentials)


def ensure_dataset(client: bigquery.Client) -> None:
    dataset_ref = bigquery.Dataset(f"{PROJECT_ID}.{DATASET_ID}")
    dataset_ref.location = DATASET_LOCATION
    client.create_dataset(dataset_ref, exists_ok=True)
    logger.info("Dataset `%s.%s` pronto.", PROJECT_ID, DATASET_ID)


def load_csv_to_bigquery() -> None:
    client = get_bigquery_client()
    ensure_dataset(client)

    for table in TABLES:
        csv_path = RAW_DATA_PATH / f"{table}.csv"
        if not csv_path.exists():
            raise FileNotFoundError(f"CSV nao encontrado: {csv_path}")

        logger.info("Iniciando carga da tabela `%s` a partir de `%s`.", table, csv_path)
        df = pd.read_csv(csv_path)
        table_ref = f"{PROJECT_ID}.{DATASET_ID}.{table}"
        job_config = bigquery.LoadJobConfig(
            write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
            autodetect=True,
        )

        job = client.load_table_from_dataframe(df, table_ref, job_config=job_config)
        job.result()

        logger.info(
            "Carga concluida para `%s` com %s registros em `%s`.",
            table,
            len(df),
            table_ref,
        )

    logger.info("Carga completa no BigQuery.")


if __name__ == "__main__":
    load_csv_to_bigquery()
