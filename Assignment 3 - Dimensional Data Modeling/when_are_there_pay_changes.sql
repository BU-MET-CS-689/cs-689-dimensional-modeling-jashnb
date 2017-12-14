
select elps.months_elpsd_total,  count(pfac.ratechangedate)
from hr_datawarehouse.elapsed_days_dimension elps
   join hr_datawarehouse.pay_change_facts pfac on (elps.day_key = pfac.tenure_day_key)
   join hr_datawarehouse.employee_dimension emp on (pfac.employee_key = emp.employee_key)
where pfac.ratechangedate > emp.hiredate
group by elps.months_elpsd_total
order by 2 desc
;

select elps.months_elpsd_latest_year,  count(pfac.ratechangedate)
from hr_datawarehouse.elapsed_days_dimension elps
   join hr_datawarehouse.pay_change_facts pfac on (elps.day_key = pfac.tenure_day_key)
   join hr_datawarehouse.employee_dimension emp on (pfac.employee_key = emp.employee_key)
where pfac.ratechangedate > emp.hiredate
group by elps.months_elpsd_latest_year
order by 2 desc
;

