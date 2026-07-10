EXPORT DATA OPTIONS(
  uri='gs://saycheese-484314-datalake/raw_events/event_date={_TABLE_SUFFIX}/*.parquet',
  format='PARQUET',
  overwrite=true
) AS
SELECT *
FROM `saycheese-484314.analytics_517953491.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20260115' AND FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE('Asia/Seoul'), INTERVAL 2 DAY));