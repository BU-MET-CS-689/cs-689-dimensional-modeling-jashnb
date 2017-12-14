DROP TABLE IF EXISTS hr_datawarehouse.pay_change_facts;

CREATE TABLE hr_datawarehouse.pay_change_facts
   AS
      SELECT
         emp.employee_key,
         emp.location_key,
         pyh.ratechangedate,
         emp.hiredate,
         pyh.rate,
         pyh.prior_rate,
         pyh.payfrequency * interval '1 week' as pay_frequency,
         CAl.calendar_key,
         cast('DP' || TO_CHAR(dph.departmentid, 'FM000') AS VARCHAR(20)) AS department_key,
         extract(DAY FROM pyh.ratechangedate -
                          emp.hiredate)                                  AS days_on_job,
         cast(format('d%s_%s',
                     trim(to_char(floor(mod(extract(DAY FROM (pyh.ratechangedate - emp.hiredate)) :: INT, 12)), '00')),
                     trim(to_char(extract(DAY FROM pyh.ratechangedate - emp.hiredate), '00000'))) AS
              VARCHAR(20))                                               AS tenure_day_key
      FROM hr_datawarehouse.employee_dimension emp
         JOIN (SELECT
                  businessentityid,
                  rate,
                  ratechangedate,
                  payfrequency,
                  lag(rate)
                  OVER (
                     PARTITION BY businessentityid
                     ORDER BY ratechangedate ) as prior_rate
               FROM humanresources.employeepayhistory) PYH ON
                                                              (EMP.employee_key =
                                                               'EM' || TO_CHAR(PYH.businessentityid, 'FM00000000'))
         JOIN humanresources.employeedepartmenthistory DPH ON (
            PYH.businessentityid = DPH.businessentityid AND
            PYH.ratechangedate BETWEEN DPH.startdate AND COALESCE(DPH.enddate, CURRENT_DATE + INTERVAL '100 year')
            )
         JOIN hr_datawarehouse.calendar_dimension cal ON (
            cal.year_with_month_day = to_char(pyh.ratechangedate, 'YYYY-MM-DD')
            );

SELECT *
FROM hr_datawarehouse.pay_change_facts
limit 15;

CREATE INDEX pay_change_facts_i1
   ON hr_datawarehouse.pay_change_facts (employee_key);
CREATE INDEX pay_change_facts_i2
   ON hr_datawarehouse.pay_change_facts (location_key);
CREATE INDEX pay_change_facts_i3
   ON hr_datawarehouse.pay_change_facts (calendar_key);
CREATE INDEX pay_change_facts_i4
   ON hr_datawarehouse.pay_change_facts (tenure_day_key);
CREATE INDEX pay_change_facts_i5
   ON hr_datawarehouse.pay_change_facts (department_key);

ALTER TABLE hr_datawarehouse.pay_change_facts
   ADD CONSTRAINT pay_change_facts_f1 FOREIGN KEY (employee_key) REFERENCES hr_datawarehouse.employee_dimension (employee_key);
ALTER TABLE hr_datawarehouse.pay_change_facts
   ADD CONSTRAINT pay_change_facts_f2 FOREIGN KEY (location_key) REFERENCES hr_datawarehouse.location_dimension (location_key);
ALTER TABLE hr_datawarehouse.pay_change_facts
   ADD CONSTRAINT pay_change_facts_f3 FOREIGN KEY (calendar_key) REFERENCES hr_datawarehouse.calendar_dimension (calendar_key);
ALTER TABLE hr_datawarehouse.pay_change_facts
   ADD CONSTRAINT pay_change_facts_f4 FOREIGN KEY (tenure_day_key) REFERENCES hr_datawarehouse.elapsed_days_dimension (day_key);
ALTER TABLE hr_datawarehouse.pay_change_facts
   ADD CONSTRAINT pay_change_facts_f5 FOREIGN KEY (department_key) REFERENCES hr_datawarehouse.department_dimension (department_key);