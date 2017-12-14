drop TABLE IF EXISTS hr_datawarehouse.department_dimension;

create table hr_datawarehouse.department_dimension
   AS
select
   cast ('DP' || TO_CHAR(dept.departmentid, 'FM000') as VARCHAR(20)) AS department_key,
   departmentid,
   name as department_name,
   groupname as department_group_name
FROM
   humanresources.department dept;

ALTER TABLE hr_datawarehouse.department_dimension add CONSTRAINT department_dimension_pk PRIMARY KEY (department_key);

ALTER TABLE hr_datawarehouse.department_dimension add CONSTRAINT department_dimension_u1 UNIQUE (departmentid, department_key);

ALTER TABLE hr_datawarehouse.department_dimension add CONSTRAINT department_dimension_u2 UNIQUE (department_name, department_key);

ALTER TABLE hr_datawarehouse.department_dimension add CONSTRAINT department_dimension_u3 UNIQUE (department_group_name, department_key);

select * from hr_datawarehouse.department_dimension;