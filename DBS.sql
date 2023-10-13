/***********************************
Assignment 1 - DBS 311
Julia Alekssev, 051292134
Ka Ying Chan, 123231227
Audrey Duzon, 019153147
2023-10-13
**********************************/

-- Q1
SELECT 
    employee_id,
    SUBSTR(INITCAP(last_name) || ', ' || INITCAP(first_name), 1, 25) AS Fullname,  
    job_id,
    TO_CHAR(LAST_DAY(hire_date), '[Month ddth "of" YYYY]') AS "Start Date"
FROM employees
WHERE
    EXTRACT(MONTH FROM hire_date) IN (5, 11) 
    AND EXTRACT(YEAR FROM hire_date) NOT IN ('2015', '2016')
ORDER BY hire_date DESC;

---------------------------------------------------------------------------------------------------
--Q2
--as per clint, 1 use of CASE is ok. This is the only question using case
SELECT 
    'Emp# ' || employee_id || ' named ' || first_name || ' ' || last_name || ' who is ' || job_id || ' will have a new salary of $' || 
    CASE 
        WHEN UPPER(job_id) LIKE '%VP%' THEN ROUND(salary * 1.25, 2) 
        ELSE ROUND(salary * 1.18, 2) 
    END AS "Employees with increased Pay"
FROM employees 
WHERE 
    (salary <= 6500 OR salary >= 11500) 
    AND (UPPER(job_id) LIKE '%VP%' OR UPPER(job_id) LIKE '%MAN%' OR UPPER(job_id) LIKE '%MGR%') 
    AND UPPER(job_id) NOT LIKE '%PRES%'
ORDER BY salary DESC;

---------------------------------------------------------------------------------------------------
--Q3
SELECT
    last_name,
    salary,
    job_id,
    NVL(TO_CHAR(manager_id), 'NONE') AS Manager#,
    TO_CHAR(((salary + (salary * NVL(commission_pct, 0)))*12 + 1000), '$9,999,999.00') AS "Total Income"
FROM employees
WHERE 
    (commission_pct IS NULL OR department_id = 80) 
    AND (salary + (salary * NVL(commission_pct, 0)) + 1000) > 15000
ORDER BY "Total Income" DESC;

---------------------------------------------------------------------------------------------------
--Q4
SELECT
    department_id,
    job_id,
    TO_CHAR(MIN(salary), '$999,999.99')AS "Lowest Dept/Job Pay"
FROM employees
WHERE 
    UPPER(job_id) NOT LIKE ('%REP%') 
    AND department_id NOT IN(60,80)
GROUP BY 
    department_id, 
    job_id
HAVING MIN(salary) BETWEEN 6500 AND 16800
ORDER BY
    department_id, 
    job_id;

---------------------------------------------------------------------------------------------------
--Q5
--showing all employees PAID MORE than 10320 (highest pay amongth lowest is Taylor 10320== 8600 + (8600*0.2))
--USING PAID comparison as per clint's formula salay + salarly*commission_pct
--Hunold earns 9000, which is less than 10320
--taylor earns exactly 10320 which is exact and NOT GREATER THAN
SELECT 
    UPPER(SUBSTR(last_name,0,1))||  SUBSTR(last_name, 2) AS last_name,
    salary,
    job_id
FROM employees
WHERE employee_id IN (
    SELECT employee_id
    FROM employees
    MINUS
    SELECT employee_id
    FROM employees
    WHERE job_id LIKE '%VP%'
        OR job_id LIKE '%PRES%'
    )
    AND (salary + (NVL(commission_pct,0)* salary)) > (
        SELECT MAX(salary) 
        FROM (
            SELECT 
                MIN(salary + (NVL(commission_pct,0)* salary)) salary,
                department_id
            FROM employees
            WHERE department_id IN (
                SELECT d.department_id
                FROM departments d
                    JOIN locations l ON d.location_id = l.location_id
                    JOIN countries c ON l.country_id = c.country_id
                WHERE c.country_id != 'US'
            )
            GROUP BY department_id
        )
    )
ORDER BY job_id ASC;

---------------------------------------------------------------------------------------------------
-- Q6
--no joins allowed
--worst paid == 8300
--return only if employee dep in 60 || 20
SELECT
    last_name,
    salary,
    job_id
FROM employees e
WHERE (salary*(1+NVL(commission_pct, 0))) > (
    SELECT MIN(salary*(1+NVL(commission_pct, 0))) AS MIN_PAY_ACCT 
    FROM employees
    WHERE department_id = 110
    GROUP BY department_id
    )
    AND e.department_id IN (20, 60)
ORDER BY UPPER(last_name);

---------------------------------------------------------------------------------------------------
--Q7
--showing all employees earning less than the BEST PAID unionized worker (value == 14300)
--unionized worker is NOT in jobID 'AD%' or a manager
--AND only if they work in sales or marketing, AND NOT PRES or MANAGER
SELECT
    SUBSTR(UPPER(SUBSTR(first_name,0,1))||  SUBSTR(first_name, 2) || ' ' || UPPER(SUBSTR(last_name,0,1))||  SUBSTR(last_name, 2),0,24) AS Employee,
    job_id,
    LPAD(TO_CHAR(TO_CHAR(salary, '$999,999')), 16, '=') AS Salary,
    department_id
FROM employees
WHERE salary + (salary * NVL(commission_pct,0)) < (
    SELECT MAX(salary + (salary * NVL(commission_pct,0)))
    FROM employees e
    WHERE employee_id IN (
        SELECT employee_id
        FROM employees
        WHERE employee_id NOT IN(
            SELECT m.employee_id
            FROM employees e
                JOIN employees m ON e.manager_id = m.employee_id
            UNION
            SELECT employee_id
            FROM employees
            WHERE UPPER(job_id) LIKE '%PRES' OR UPPER(job_id) LIKE '%VP'
            )
        )
    )
    AND job_id LIKE 'SA%'
    OR job_id LIKE 'MK%'
ORDER BY Employee ASC;
    
---------------------------------------------------------------------------------------------------
--Q8
SELECT 
    COALESCE(d.department_name, 'Not Assigned Yet') AS Department,
    COALESCE(SUBSTR(l.city, 1, 22), 'Not Assigned Yet') AS City,
    COALESCE(e.job_id, 'No employees') AS Department,
    COUNT(DISTINCT e.job_id) AS "# of Jobs"
FROM employees e
    FULL OUTER JOIN departments d ON e.department_id = d.department_id
    FULL OUTER JOIN locations l ON d.location_id = l.location_id
GROUP BY
    COALESCE(d.department_name, 'Not Assigned Yet'),
    COALESCE(SUBSTR(l.city, 1, 22), 'Not Assigned Yet'),
    COALESCE(e.job_id, 'No employees')
ORDER BY
    "# of Jobs",
    COALESCE(d.department_name, 'Not Assigned Yet'),
    City;