
drop table if exists hr_datawarehouse.location_dimension;

create table hr_datawarehouse.location_dimension
AS
select
   'LC|' || countryregionname || '|' || city|| '|' || postalcode as location_key,
   city as city_name,
   stateprovincename,
   postalcode,
   countryregionname,
   countryregionname || '|' || stateprovincename as absolute_state_province,
   countryregionname || '|' || stateprovincename || '|' || city as absolute_city,
   countryregionname || '|' || postalcode as absolute_postal_code
from (select DISTINCT city, stateprovincename, postalcode, countryregionname from  humanresources.vemployee) locsource
;

select *
from hr_datawarehouse.location_dimension
;

alter TABLE hr_datawarehouse.location_dimension add CONSTRAINT location_dimension_pk PRIMARY KEY (location_key);

alter TABLE hr_datawarehouse.location_dimension add CONSTRAINT location_dimension_u1 UNIQUE (absolute_postal_code, location_key);

alter TABLE hr_datawarehouse.location_dimension add CONSTRAINT location_dimension_u2 UNIQUE (absolute_state_province, location_key);

alter TABLE hr_datawarehouse.location_dimension add CONSTRAINT location_dimension_u3 UNIQUE (countryregionname, location_key);



