#!/bin/bash
set -e

RUN_DATE=$(date -v-1d '+%Y%m%d')  # 어제 날짜 (Mac 기준, 서버는 date -d 사용)

echo "Exporting raw events for $RUN_DATE to GCS..."
sed "s/@run_date/${RUN_DATE}/g" sql/01_export_raw_to_gcs.sql > /tmp/export_query.sql
bq query --use_legacy_sql=false < /tmp/export_query.sql

echo "Pipeline completed successfully."