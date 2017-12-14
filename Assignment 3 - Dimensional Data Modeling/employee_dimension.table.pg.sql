
drop table if exists hr_datawarehouse.employee_dimension;

create table hr_datawarehouse.employee_dimension
AS
select
   'EM' || TO_CHAR(businessentityid, 'FM00000000') as EMPLOYEE_key,
   (select hiredate from humanresources.employee em where em.businessentityid = vem.businessentityid) as hiredate,
   jobtitle,
   'LC|' || countryregionname || '|' || city|| '|' || postalcode as location_key
from humanresources.vemployee vem
;

select *
from hr_datawarehouse.employee_dimension
;

alter TABLE hr_datawarehouse.employee_dimension add CONSTRAINT employee_dimension_pk PRIMARY KEY (employee_key);

ALTER TABLE hr_datawarehouse.employee_dimension add CONSTRAINT employee_dimension_u1 UNIQUE (jobtitle, employee_key);

alter TABLE hr_datawarehouse.employee_dimension add CONSTRAINT employee_dimension_u2 UNIQUE (location_key, employee_key);

ALTER TABLE hr_datawarehouse.employee_dimension add CONSTRAINT employee_dimension_f1 FOREIGN KEY (location_key)
   REFERENCES hr_datawarehouse.location_dimension(location_key);