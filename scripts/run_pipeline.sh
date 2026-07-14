#!/bin/bash
# set -e 제거 — 개별 날짜 에러가 전체 스크립트를 멈추지 않게

PROJECT_ID="saycheese-484314"
DATASET="analytics_517953491"
BUCKET_PATH="gs://saycheese-484314-datalake/raw_events"

START_DATE="2026-07-01"
END_DATE=$(TZ='Asia/Seoul' date -d '2 days ago' '+%Y-%m-%d')  # Linux(GNU date) 기준

echo "Fetching already-filled dates in GCS..."
GCS_DATES=$(gsutil ls -d "${BUCKET_PATH}/event_date=*/" 2>/dev/null \
  | sed -E 's#.*event_date=([0-9]{8})/#\1#' || true)

CURRENT_DATE=$START_DATE
SUCCESS_COUNT=0
SKIP_EXISTING_COUNT=0
SKIP_MISSING_COUNT=0

while [[ "$CURRENT_DATE" < "$END_DATE" || "$CURRENT_DATE" == "$END_DATE" ]]; do
  DATE_SUFFIX=$(date -d "$CURRENT_DATE" '+%Y%m%d')

  if grep -q "^${DATE_SUFFIX}$" <<< "$GCS_DATES"; then
    SKIP_EXISTING_COUNT=$((SKIP_EXISTING_COUNT + 1))
    CURRENT_DATE=$(date -d "$CURRENT_DATE + 1 day" '+%Y-%m-%d')
    continue
  fi

  echo "Trying $DATE_SUFFIX..."

  bq query --use_legacy_sql=false \
    "EXPORT DATA OPTIONS(
      uri='gs://saycheese-484314-datalake/raw_events/event_date=${DATE_SUFFIX}/*.parquet',
      format='PARQUET',
      overwrite=true
    ) AS
    SELECT *
    FROM \`${PROJECT_ID}.${DATASET}.events_${DATE_SUFFIX}\`" \
    2>/tmp/backfill_error.log

  if [ $? -eq 0 ]; then
    echo "  -> Success"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  else
    echo "  -> Skipped (table not found or error)"
    SKIP_MISSING_COUNT=$((SKIP_MISSING_COUNT + 1))
  fi

  CURRENT_DATE=$(date -d "$CURRENT_DATE + 1 day" '+%Y-%m-%d')
done

echo ""
echo "Backfill finished. Success: $SUCCESS_COUNT, Already existed: $SKIP_EXISTING_COUNT, Missing/error: $SKIP_MISSING_COUNT"