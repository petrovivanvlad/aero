#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.postgres_operator import PostgresOperator
from airflow.hooks.postgres_hook import PostgresHook
from airflow.utils.dates import days_ago
from airflow.models import Variable

import datetime as dt

import csv
from io import StringIO
import urllib.request
import json
import pandas as pd
# pd.set_option('display.expand_frame_repr', False)
# pd.set_option('display.max_columns', None)
# pd.set_option('display.max_rows', None)


CON_ID = Variable.get("connection_id")

def extract_load():

    raw_data = urllib.request.urlopen('https://random-data-api.com/api/cannabis/random_cannabis?size=10')

    processed_data = json.loads(raw_data.read())

    new_list = []
    for data in processed_data:
        inner_list = data['id'], data['uid'], json.dumps(data)
        new_list.append(inner_list)

    df = pd.DataFrame(new_list, columns=['id', 'uid', 'data'])
    # print(df)

    def split_dataframe(df, chunk_size=500):
        chunks = list()
        num_chunks = len(df) // chunk_size + 1
        for i in range(num_chunks):
            chunks.append(df[i * chunk_size:(i + 1) * chunk_size])
            # print(i)
        return chunks

    # batch:
    if not df.empty:
        df_list = split_dataframe(df, chunk_size=500)
        for i in range(len(df_list)):
            sio = StringIO()
            sio.write(df_list[i].to_csv(
                index=False, sep="\t", na_rep="NUL", quoting=csv.QUOTE_NONE,
                header=False, float_format="%.8f", doublequote=False, escapechar="\\", encoding='utf-8'))
            sio.seek(0)  # reset the position to the start of the stream

            dst_stmt = """
                    COPY staging.random_cannabis(
                        id,
                        bid,
                        data)
                    FROM STDIN
                    WITH (FORMAT TEXT);
                    COMMIT TRANSACTION;
                """
            print(dst_stmt)

            pg_cur = PostgresHook(postgres_conn_id=CON_ID).get_conn().cursor("pg_server_cursor")
            pg_cur.copy_expert(dst_stmt, sio)

with DAG(
    "random_cannabis",
    description="DAG для загрузки данных Random Cannabis",
    tags=["dwh_layer", "staging", "warehouse", "stream", "random cannabis api"],
    start_date=dt.datetime(2022, 8, 23),
    schedule_interval="0 */12 * * *",
    max_active_runs=1,
    catchup=False,
    default_args={
        'owner': 'airflow',
        'depends_on_past': False,
        "email": ["petrovivanvlad@yandex.ru"],
        "email_on_failure": True,
        "email_on_retry": True,
        'start_date': days_ago(2)
    }
) as dag:

    extract_load = PythonOperator(
        task_id='extract_load',
        python_callable=extract_load,
        dag=dag,
    )
    transform = PostgresOperator(
        task_id="transform",
        sql="./sql/dml/extract_random.sql",
        postgres_conn_id=CON_ID,
        dag=dag,
    )

    extract_load >> transform

