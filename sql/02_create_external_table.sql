CREATE OR REPLACE EXTERNAL TABLE `saycheese-484314.saycheese_mart.raw_events_external`
WITH PARTITION COLUMNS (event_date STRING)
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://saycheese-484314-datalake/raw_events/*'],
  hive_partition_uri_prefix = 'gs://saycheese-484314-datalake/raw_events'
);