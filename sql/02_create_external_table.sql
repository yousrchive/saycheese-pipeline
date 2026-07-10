CREATE OR REPLACE EXTERNAL TABLE `saycheese-484314.analytics_517953491.raw_events_external`
WITH PARTITION COLUMNS (event_date DATE)
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://saycheese-484314-datalake/raw_events/event_date=*/*.parquet'],
  hive_partition_uri_prefix = 'gs://saycheese-484314-datalake/raw_events'
);