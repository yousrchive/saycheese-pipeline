CREATE OR REPLACE VIEW `saycheese-484314.analytics_517953491.staging_data` AS
SELECT * EXCEPT(row_num)
FROM (
  SELECT
    event_date,
    event_timestamp AS event_ts_micros,
    TIMESTAMP_MICROS(event_timestamp) AS event_ts,
    event_name,
    user_id,
    user_pseudo_id,
    COALESCE(user_id, user_pseudo_id) AS unified_user_key,

    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS ga_session_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_number') AS ga_session_number,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location') AS page_location,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_referrer') AS page_referrer,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_title') AS page_title,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'engagement_time_msec') AS engagement_time_msec,
    (SELECT COALESCE(value.string_value, CAST(value.int_value AS STRING)) FROM UNNEST(event_params) WHERE key = 'session_engaged') AS session_engaged,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'entry_source') AS entry_source,

    platform,
    device.category AS device_category,
    device.operating_system AS operating_system,
    COALESCE(geo.city, geo.region) AS region,

    traffic_source.source AS ts_source,
    traffic_source.medium AS ts_medium,
    traffic_source.name AS ts_campaign,

    collected_traffic_source.manual_source AS utm_source,
    collected_traffic_source.manual_medium AS utm_medium,
    collected_traffic_source.manual_campaign_name AS utm_campaign,
    collected_traffic_source.manual_term AS utm_term,
    collected_traffic_source.manual_content AS utm_content,

    ROW_NUMBER() OVER (
      PARTITION BY event_date, user_pseudo_id, event_timestamp, event_name
      ORDER BY event_timestamp
    ) AS row_num

  FROM `saycheese-484314.analytics_517953491.raw_events_external`
)
WHERE row_num = 1;