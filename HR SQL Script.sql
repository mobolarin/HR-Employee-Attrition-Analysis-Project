create database ibm;
use ibm;
show tables;
-- rename the table for simplicity and ease
alter table `ibm hr-employee-attrition` rename to employees; 
select * from employees;

-- Cleaning/EDA
-- a. count no of rows, unique id's & attrition
select count(*) as total_records from employees; -- 1470 rows 
select count(distinct EmployeeID) as unique_ids from employees; -- 1470 unique id's
select distinct Attrition from employees; -- yes/no

-- b. Rename the age column
set sql_safe_updates=0;
start transaction;
alter table employees
change column ï»¿Age Age int;

-- c. Drop unwanted columns (Over18, EmployeeCount, StandardHours)
start transaction;
alter table employees
drop column Over18,
drop column EmployeeCount,
drop column StandardHours;

/* d. Convert EmployeeNumber to EmployeeID column 
as primary key to solve problem of uniqueness,
then move it to be the first column */
start transaction;
alter table employees 
change column EmployeeNumber EmployeeID int;
select * from employees;

alter table employees
modify EmployeeID int not null primary key first;

-- e. Starting EDA by checking for nulls
select Age from employees where Age = ''; -- no nulls

select sum(case when Age is null then 1 else 0 end) as age_nulls,
	   sum(case when Attrition is null then 1 else 0 end) as attrition_nulls,
       sum(case when BusinessTravel is null then 1 else 0 end) as travel_nulls,
       sum(case when Department is null then 1 else 0 end) as dept_nulls,
	   sum(case when Education is null then 1 else 0 end) as edu_nulls,
       sum(case when EducationField is null then 1 else 0 end) as field_nulls,
       sum(case when Gender is null then 1 else 0 end) as gender_nulls,
       sum(case when JobLevel is null then 1 else 0 end) as level_nulls,
       sum(case when JobRole is null then 1 else 0 end) as role_nulls,
       sum(case when JobSatisfaction is null then 1 else 0 end) as satisfaction_nulls,
       sum(case when MaritalStatus is null then 1 else 0 end) as status_nulls,
       sum(case when YearsAtCompany is null then 1 else 0 end) as year_nulls 
from employees; -- no nulls found

-- e. Continue EDA using the select distinct keyword
select * from employees;
select distinct Age from employees order by Age asc; -- Age ranges from 18-60
select distinct BusinessTravel from employees;
select distinct Department from employees;
select distinct Education from employees;
select distinct EducationField from employees;
select distinct Gender from employees;
select distinct JobLevel from employees;
select distinct JobRole from employees;


-- f. Correct the records in the BusinessTravel column
start transaction;
update employees
set BusinessTravel = 'Travel Rarely'
where BusinessTravel = 'Travel_Rarely';

update employees
set BusinessTravel = 'Travel Frequently'
where BusinessTravel = 'Travel_Frequently';

-- f. Check out for outliers
select min(Age), max(Age), avg(Age) from employees;
select min(MonthlyIncome), max(MonthlyIncome), avg(MonthlyIncome) from employees;
	
-- g. Add Columns- AgeGroup, IncomeBand
set sql_safe_updates = 0; 
start transaction;
alter table employees
add column AgeGroup varchar(20) after Age,
add column IncomeBand varchar(20) after MonthlyIncome;
select * from employees;

update employees
Set AgeGroup = case 
	when Age between 18 and 26 then '18-26'
	when Age between 27 and 35 then '27-35'
	when Age between 36 and 44 then '36-44'
	when Age between 45 and 53 then '45-53'
	when Age between 54 and 60 then '54-60'
	else 'Other'
end,
IncomeBand = case 
	when MonthlyIncome between 1000 and 4999 then '1-5k'
	when MonthlyIncome between 5000 and 9999 then '5-10k'
	when MonthlyIncome between 10000 and 14999 then '10-15k'
	when MonthlyIncome between 15000 and 19999 then '15-20k'
	else '20k+'
end;
select * from employees;

start transaction;
update employees
set IncomeBand = '1-5k'
where IncomeBand = '1k-5k';

update employees
set IncomeBand = '5-10k'
where IncomeBand = '5k-10k';

update employees
set IncomeBand = '10-15k'
where IncomeBand = '10k-15k';

update employees
set IncomeBand = '15-20k'
where IncomeBand = '15k-20k';

select distinct IncomeBand from employees;
select distinct AgeGroup from employees;
