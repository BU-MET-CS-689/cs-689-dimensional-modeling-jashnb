drop table if exists hr_datawarehouse.elapsed_days_dimension CASCADE;

create table
   hr_datawarehouse.elapsed_days_dimension as
WITH
      span AS (
      SELECT
         20 AS years_back,
         2  AS years_future
),
      parms AS (SELECT 365.2422 AS days_in_year)
SELECT
   cast (format('d%s_%s', trim(to_char(floor(mod(total_days_elapsed, 12)), '00')), trim(to_char(total_days_elapsed, '00000'))) as varchar(20)) as day_key,
   total_days_elapsed as days_elpsd_total,
   total_days_elapsed * INTERVAL '1 day' as elapsed_interval,
   mod(total_days_elapsed, 7) as days_elpsd_latest_week,
   cast (floor (mod (total_days_elapsed, (days_in_year/12))) as bigint) as days_elpsd_latest_month,
   cast (floor (mod (total_days_elapsed, days_in_year)) as BIGINT) as days_elpsd_latest_year,
   total_weeks_elapsed as weeks_elapsed_total,
   cast (floor (mod (mod (total_days_elapsed, (days_in_year/12)), 7)) as bigint) as weeks_elpsd_latest_month,
   cast (floor (mod (total_days_elapsed, days_in_year)/7) as BIGINT) as weeks_elpsd_latest_year,
   total_months_elapsed as months_elpsd_total,
   cast (floor (mod (total_months_elapsed, 12)) as BIGINT) as months_elpsd_latest_year,
   years_elapsed
FROM parms, (
        SELECT
           days_elapsed as total_days_elapsed,
           cast (floor(days_elapsed / 7) as BIGINT)                 AS total_weeks_elapsed,
           cast (floor(12 * days_elapsed / days_in_year) as BIGINT) AS total_months_elapsed,
           cast (floor(days_elapsed / days_in_year) as BIGINT)     AS years_elapsed
        FROM parms, (
                       SELECT gen_num::BIGINT AS days_elapsed
                       FROM (SELECT generate_series(0, 365 * (years_back + years_future)) AS gen_num
                             FROM span
                            ) gens
                    ) dayoffset)
     daypieces
;

SELECT *
FROM hr_datawarehouse.elapsed_days_dimension
limit 15
;

ALTER TABLE hr_datawarehouse.elapsed_days_dimension add CONSTRAINT elapsed_days_dimension_pk PRIMARY KEY (day_key);

alter table hr_datawarehouse.elapsed_days_dimension ADD CONSTRAINT elapsed_days_dimension_u01 UNIQUE (days_elpsd_total, day_key);

alter table hr_datawarehouse.elapsed_days_dimension ADD CONSTRAINT elapsed_days_dimension_u02 UNIQUE (elapsed_interval, day_key);

alter table hr_datawarehouse.elapsed_days_dimension ADD CONSTRAINT elapsed_days_dimension_u03 UNIQUE (weeks_elapsed_total, day_key);

alter table hr_datawarehouse.elapsed_days_dimension ADD CONSTRAINT elapsed_days_dimension_u04 UNIQUE (months_elpsd_total, day_key);

alter table hr_datawarehouse.elapsed_days_dimension ADD CONSTRAINT elapsed_days_dimension_u05 UNIQUE (years_elapsed, day_key);
