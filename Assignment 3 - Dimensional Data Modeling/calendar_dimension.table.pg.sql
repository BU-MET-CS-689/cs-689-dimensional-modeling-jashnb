DROP TABLE IF EXISTS hr_datawarehouse.calendar_dimension CASCADE;

CREATE TABLE
   hr_datawarehouse.calendar_dimension AS
WITH
      span AS (
         SELECT
            20 AS years_back,
            2  AS years_future
   )
select
   'c' || to_char (mod(day_number, 12), 'FM00') || '_' || to_char (day_number, 'FM000000000') AS CALENDAR_KEY,
   date_value,
   day_of_week,
   DAY_NAME,
   day_of_month,
   day_of_year,
   TO_CHAR(YEAR, 'FM0000') || '-' || TO_CHAR(month_of_year, 'FM00') || '-' || to_char (day_of_month, 'FM00') AS YEAR_WITH_MONTH_DAY,
   week_of_year,
   TO_CHAR(YEAR, 'FM0000') || 'w' || TO_CHAR(week_of_year, 'FM00') AS year_with_week,
   month_of_year,
   TO_CHAR(YEAR, 'FM0000') || '-' || TO_CHAR(month_of_year, 'FM00') AS year_with_month,
   quarter_of_year,
   TO_CHAR(YEAR, 'FM0000') || 'CQ' || TO_CHAR(quarter_of_year, 'FM0') AS year_with_quarter,
   year
from (
   SELECT
      day_number,
      date_value,
      extract(DOW FROM date_value)::BIGINT     AS day_of_week,
      to_char(date_value, 'DY') AS DAY_NAME,
      extract(DAY FROM date_value)::BIGINT     AS day_of_month,
      extract(DOY FROM date_value)::BIGINT     AS day_of_year,
      extract(WEEK FROM date_value)::BIGINT    AS week_of_year,
      extract(MONTH FROM date_value)::BIGINT   AS month_of_year,
      extract(QUARTER FROM date_value)::BIGINT AS quarter_of_year,
      extract(YEAR FROM date_value)::BIGINT    AS year
   FROM (
           SELECT
              gen_num                                   AS day_number,
              start_date + (gen_num * INTERVAL '1 day') AS date_value
           FROM
              (
                 SELECT
                    current_date - (years_back * INTERVAL '1 year')                 AS start_date,
                    generate_series(1, 365 * (years_back + years_future)) :: BIGINT AS gen_num
                 FROM span
              ) firstvals
        ) basecal
) morecal
;

select *
from hr_datawarehouse.calendar_dimension
limit 15;

alter table hr_datawarehouse.calendar_dimension add constraint calendar_dimension_pk PRIMARY KEY (calendar_key);

alter table hr_datawarehouse.calendar_dimension add constraint calendar_dimension_u01 UNIQUE (date_value);

alter table hr_datawarehouse.calendar_dimension add constraint calendar_dimension_u02 UNIQUE (year, date_value, calendar_key);

alter table hr_datawarehouse.calendar_dimension add constraint calendar_dimension_u03 UNIQUE (year_with_quarter, date_value, calendar_key);

alter table hr_datawarehouse.calendar_dimension add constraint calendar_dimension_u04 UNIQUE (year_with_month , date_value, calendar_key);

alter table hr_datawarehouse.calendar_dimension add constraint calendar_dimension_u05 UNIQUE (year_with_week, date_value, calendar_key);

alter table hr_datawarehouse.calendar_dimension add constraint calendar_dimension_u06 UNIQUE (YEAR_WITH_MONTH_DAY, date_value, calendar_key);

alter table hr_datawarehouse.calendar_dimension add constraint calendar_dimension_u07 UNIQUE (month_of_year, date_value, calendar_key);

alter table hr_datawarehouse.calendar_dimension add constraint calendar_dimension_u08 UNIQUE (DAY_NAME, date_value, calendar_key);

alter table hr_datawarehouse.calendar_dimension add constraint calendar_dimension_u09 UNIQUE (YEAR_WITH_MONTH_DAY);
