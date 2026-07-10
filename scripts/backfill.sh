#!/bin/bash
# set -e 제거 — 에러 나도 스크립트 전체가 멈추지 않게

START_DATE="2026-01-01"
END_DATE=$(date -v-2d '+%Y-%m-%d')

CURRENT_DATE=$START_DATE
SUCCESS_COUNT=0
SKIP_COUNT=0

while [[ "$CURRENT_DATE" < "$END_DATE" || "$CURRENT_DATE" == "$END_DATE" ]]; do
  DATE_SUFFIX=$(date -jf "%Y-%m-%d" "$CURRENT_DATE" "+%Y%m%d")
  echo "Trying $DATE_SUFFIX..."

  bq query --use_legacy_sql=false \
    "EXPORT DATA OPTIONS(
      uri='gs://saycheese-484314-datalake/raw_events/event_date=${DATE_SUFFIX}/*.parquet',
      format='PARQUET',
      overwrite=true
    ) AS
    SELECT *
    FROM \`saycheese-484314.analytics_517953491.events_${DATE_SUFFIX}\`" \
    2>/tmp/backfill_error.log

  if [ $? -eq 0 ]; then
    echo "  -> Success"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  else
    echo "  -> Skipped (table not found or error)"
    SKIP_COUNT=$((SKIP_COUNT + 1))
  fi

  CURRENT_DATE=$(date -jf "%Y-%m-%d" -v+1d "$CURRENT_DATE" "+%Y-%m-%d")
done

echo ""
echo "Backfill finished. Success: $SUCCESS_COUNT, Skipped: $SKIP_COUNT"