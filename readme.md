
DAG для загрузки данных Random Cannabis
  
| Stack           |  
|-----------------|
| Python, Airflow |
| PostgreSQL      |
    

1. parsing api - https://random-data-api.com/api/cannabis/random_cannabis?size=10

2. extract json to warehouse via streaming data through staging layer using micro-batches

Requerements:
Airflow > v2.5.1
PostgreSQL > v14.0

Airflow variablie with login + password to local PostgreSQL
