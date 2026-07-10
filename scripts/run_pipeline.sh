#!/bin/bash
set -e

if [[ "$OSTYPE" == "darwin"* ]]; then
  RUN_DATE=$(TZ='Asia/Seoul' date -v-1d '+%Y%m%d')  # Mac
else
  RUN_DATE=$(TZ='Asia/Seoul' date -d 'yesterday' '+%Y%m%d')  # Linux
fi

echo "Exporting raw events for $RUN_DATE to GCS..."
sed "s/@run_date/${RUN_DATE}/g" sql/01_export_raw_to_gcs.sql > /tmp/export_query.sql
bq query --use_legacy_sql=false < /tmp/export_query.sql

echo "Pipeline completed successfully."