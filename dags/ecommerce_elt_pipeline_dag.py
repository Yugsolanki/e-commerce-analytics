from datetime import timedelta, datetime
import os
from airflow.sdk import DAG
from airflow.providers.standard.operators.empty import EmptyOperator
from airflow.providers.standard.operators.python import PythonOperator
from airflow.providers.amazon.aws.hooks.s3 import S3Hook

def upload_via_hook(local_dir, bucket_name, aws_conn_id):
    hook = S3Hook(aws_conn_id=aws_conn_id)
    
    if not hook.check_for_bucket(bucket_name):
        hook.create_bucket(bucket_name)
    
    for filename in os.listdir(local_dir):
        local_path = os.path.join(local_dir, filename)
        if os.path.isfile(local_path):
            print(f"Uploading {filename} to MinIO")
            hook.load_file(
                filename=local_path,
                key=f"uploads/raw/{filename}",
                bucket_name=bucket_name,
                replace=True
            )

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
    
    # Task to upload files to MinIO using S3Hook
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
    
    # End of the DAG
    end = EmptyOperator(task_id="end")
    
    start >> upload_task >> end