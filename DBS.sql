/***********************************
Assignment 1 - DBS 311
Julia Alekssev, 051292134
Ka Ying Chan, 123231227
Audrey Duzon, 019153147
**********************************/

--Q1
SELECT 
    employee_id,
    RPAD(SUBSTR(last_name || ', ' || first_name, 1, 25), 25) AS "FullName",
    job_id,
    '[' || TO_CHAR(LAST_DAY(ADD_MONTHS(hire_date, 1) - 1), 'Mon DDth "of" YYYY') || ']' AS "HireDate"
FROM
    employees
WHERE
    EXTRACT(MONTH FROM hire_date) IN (5, 11) AND
    EXTRACT(YEAR FROM hire_date) NOT IN ('2015', '2016')
ORDER BY
    hire_date DESC;


--Q2
CREATE OR REPLACE VIEW newSal AS
SELECT 
    'Employees with increased Pay' AS "heading",
    'Emp# ' || m.employee_id || ' named ' || m.first_name || ' ' || m.last_name || ' who is ' || m.job_id || ' will have a new salary of $' || 
    (CASE WHEN m.job_id LIKE '%VP' THEN (m.salary * 1.25) ELSE (m.salary * 1.18) END) AS "sample line"
FROM
    employees e
JOIN
    employees m ON e.manager_id = m.employee_id
WHERE m.job_id NOT LIKE '%PRES' 
    AND (m.salary < 6500 OR m.salary > 11500)
ORDER BY 
    e.salary DESC,
    m.last_name;

SELECT DISTINCT * FROM newSal;

--DROP VIEW newSal;
--Q3









