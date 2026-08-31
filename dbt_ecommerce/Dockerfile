FROM python:3.12-slim

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*
RUN pip install --upgrade pip
RUN pip install dbt-postgres

WORKDIR /usr/app/dbt

COPY . .