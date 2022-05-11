
-- CTEs --------------------------------------------------------

-- 1: Calculate the average salary of all employees.
SELECT AVG(salary) FROM employees;

-- 2: Calculate the average salary of the employees in each team (hint: you'll need to JOIN and GROUP BY here).
SELECT
departments.name,
AVG(salary)
FROM employees
INNER JOIN departments
ON employees.department_id = departments.id
GROUP BY departments.name;

-- 3: Using a CTE find the ratio of each employees salary to their team average, eg. an employee earning £55000 in a team where the average is £50000 has a ratio of 1.1.
WITH team_average_salary AS
(SELECT
department_id,
AVG(salary) AS team_salary
FROM employees
INNER JOIN departments
ON employees.department_id = departments.id
GROUP BY department_id)
SELECT 
    employees.id,
    employees.first_name,
    employees.last_name,
    employees.salary,
    team_average_salary.team_salary,
    employees.salary / team_average_salary.team_salary AS ratio
FROM employees
INNER JOIN team_average_salary
ON employees.department_id = team_average_salary.department_id;

-- 4: Find the employee with the highest ratio in Argentina.
WITH team_average_salary AS
(SELECT
department_id,
AVG(salary) AS team_salary
FROM employees
INNER JOIN departments
ON employees.department_id = departments.id
GROUP BY department_id)
SELECT 
    employees.id,
    employees.first_name,
    employees.last_name,
    employees.country,
    employees.salary,
    team_average_salary.team_salary,
    employees.salary / team_average_salary.team_salary AS ratio
FROM employees
INNER JOIN team_average_salary
ON employees.department_id = team_average_salary.department_id
WHERE employees.country = 'Argentina'
ORDER BY ratio DESC LIMIT 1;

-- 5. Extension: Add a second CTE calculating the average salary for each country and add a column showing the difference between each employee's salary and their country average.
WITH country_average_salary AS
(SELECT
country,
AVG(salary) AS country_salary
FROM employees
GROUP BY country)
SELECT 
    employees.id,
    employees.first_name,
    employees.last_name,
    employees.salary,
    country_average_salary.country_salary,
    employees.salary - country_average_salary.country_salary AS difference
FROM employees
INNER JOIN country_average_salary
ON employees.country = country_average_salary.country;


-- Window Functions --------------------------------------------

-- 1. Find the running total of salary costs as the business has grown and hired more people.
SELECT
start_date,
SUM(salary) OVER(ORDER BY start_date) AS running_total_salary
FROM employees;

-- 2. Determine if any employees started on the same day (hint: some sort of ranking may be useful here).
WITH hires_on_date(start_date, number_of_hires) AS
(SELECT
start_date,
RANK() OVER (PARTITION BY start_date ORDER BY id) AS number_of_hires
FROM employees)
SELECT
start_date,
number_of_hires
FROM hires_on_date
WHERE number_of_hires != 1;

-- This table shows that on 39 start dates, 2 employees started on the same day.
-- We could search by these start dates to find the details of the relevant employees.

-- 3. Find how many employees there are from each country.
SELECT
country,
COUNT(*)
FROM employees
GROUP BY country;

-- 4. Show how the average salary cost for each department has changed as the number of employees has increased.

-- I am not sure what this one is asking for. Running salary costs for each department? 
-- And then an average of all of these?

-- 5. Extension: Research the EXTRACT function and use it in conjunction with PARTITION and COUNT to show how many employees started working for BusinessCorp™ each year. If you're feeling adventurous you could further partition by month...


-- Combining the two -------------------------------------------

-- 1: Find the maximum and minimum salaries.
SELECT
MIN(salary),
MAX(salary)
FROM employees;

-- 2: Find the difference between the maximum and minimum salaries and each employee's own salary.
WITH max_min_salaries (employee_id, min_salary, max_salary) AS
    (SELECT
    id AS employee_id,
    MIN(salary) OVER() AS min_salary,
    MAX(salary) OVER() AS max_salary
    FROM employees)
SELECT
id,
first_name,
last_name,
salary,
salary - max_min_salaries.min_salary AS difference_from_min,
salary - max_min_salaries.max_salary AS difference_from_max
FROM employees
INNER JOIN max_min_salaries
ON employees.id = max_min_salaries.employee_id;

-- 3: Order the employees by start date. Research how to calculate the median salary value and the standard deviation in salary values and show how these change as more employees join the company.

-- 4: Limit this query to only Research & Development team members and show a rolling value for only the 5 most recent employees.

