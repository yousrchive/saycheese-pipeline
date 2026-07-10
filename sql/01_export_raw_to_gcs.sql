EXPORT DATA OPTIONS(
  uri='gs://saycheese-484314-datalake/raw_events/event_date=@run_date/*.parquet',
  format='PARQUET',
  overwrite=true
) AS
SELECT *
FROM `saycheese-484314.analytics_517953491.events_@run_date`;