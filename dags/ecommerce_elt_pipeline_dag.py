from datetime import timedelta, datetime
import os
import pandas as pd
from airflow.sdk import DAG
from airflow.providers.standard.operators.empty import EmptyOperator
from airflow.providers.standard.operators.python import PythonOperator
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.providers.docker.operators.docker import DockerOperator
from airflow.providers.docker.hooks.docker import DockerHook

UPLOAD_RAW_PREFIX = "uploads/raw/"

def upload_via_hook(local_dir, bucket_name, aws_conn_id):
    hook = S3Hook(aws_conn_id=aws_conn_id)
    
    if not hook.check_for_bucket(bucket_name):
        print(f"Creating bucket: {bucket_name}")
        hook.create_bucket(bucket_name)
    
    print(f"Uploading files from {local_dir} to MinIO bucket: {bucket_name}")
    
    for filename in os.listdir(local_dir):
        local_path = os.path.join(local_dir, filename)
        if os.path.isfile(local_path):
            print(f"Uploading {filename} to MinIO")
            hook.load_file(
                filename=local_path,
                key=f"{UPLOAD_RAW_PREFIX}{filename}",
                bucket_name=bucket_name,
                replace=True
            )
            
    print("All files have been uploaded to MinIO.")

def upload_to_postgres(bucket_name, aws_conn_id, postgres_conn_id):
    s3_hook = S3Hook(aws_conn_id=aws_conn_id)
    postgres_hook = PostgresHook(postgres_conn_id=postgres_conn_id)

    files = s3_hook.list_keys(bucket_name=bucket_name, prefix=UPLOAD_RAW_PREFIX)

    for file_key in files:
        if file_key.endswith(".csv"):
            print(f"Processing {file_key} from MinIO")
            
            file_object = s3_hook.get_key(key=file_key, bucket_name=bucket_name)
            df = pd.read_csv(file_object.get()['Body'])
            df["_loaded_at"] = datetime.now()
            
            engine = postgres_hook.get_sqlalchemy_engine()
            
            table_name = file_key.removeprefix(UPLOAD_RAW_PREFIX).removesuffix(".csv").removeprefix("olist_").removesuffix("_dataset")
            
            df.to_sql(
                name=table_name,
                schema='raw',
                con=engine,
                if_exists='append',
                index=False
            )
            
            print(f"Successfully loaded {len(df)} rows into {table_name}")
            
    print("All files have been processed and loaded into Postgres.")

with DAG(
    "e-commerce-analytics",
    default_args={
        "depends_on_past":False,
        "retries": 1,
        "retry_delay": timedelta(minutes=5),
    },
    description="E-commerce Analytics Pipeline",
    schedule=timedelta(days=1),
    start_date=datetime(2026, 8, 26),
    catchup=False,
) as dag:

    # Start of the DAG
    start = EmptyOperator(task_id="start")
    
    # Task to upload files to MinIO 
    upload_task = PythonOperator(
        task_id="upload_to_minio",
        python_callable=upload_via_hook,
        op_kwargs={
            "local_dir": os.path.abspath(
                os.path.join(os.path.dirname(__file__), "..", "data", "archive")
            ),
            "bucket_name": "ecommerce-analytics",
            "aws_conn_id": "minio_conn",
        },
    )

    # Task to upload files from MinIO to Postgres 
    upload_to_postgres_task = PythonOperator(
        task_id="upload_to_postgres",
        python_callable=upload_to_postgres,
        op_kwargs={
            "bucket_name": "ecommerce-analytics",
            "aws_conn_id": "minio_conn",
            "postgres_conn_id": "postgres_conn",
        },
    )

    run_dbt_models = DockerOperator(
        task_id="run_dbt_models",
        image="ecommerce-dbt:latest",
        command="dbt build",
        docker_url="unix://var/run/docker.sock",
        network_mode="e-commerce-analytics_default",
        auto_remove="success",
        mount_tmp_dir=False,
        environment={
            "DBT_HOST": "postgres",
            "DBT_PORT": "5432",
            "DBT_USER": os.getenv("POSTGRES_USER", "admin"),
            "DBT_PASSWORD": os.getenv("POSTGRES_PASSWORD", "admin"),
            "DBT_DBNAME": os.getenv("POSTGRES_DB", "ecommerce"),
            "DBT_SCHEMA": "dbt_dev"
        }
    )

    # End of the DAG
    end = EmptyOperator(task_id="end")
    
    start >> upload_task >> upload_to_postgres_task >> run_dbt_models >> end