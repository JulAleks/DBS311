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
SELECT
    'Employees with increased Pay' AS "heading",
    'Emp# ' || d.employee_id || ' named ' || d.first_name || ' ' || d.last_name || ' who is ' || d.job_id || ' will have a new salary of $' || 
    (CASE WHEN d.job_id LIKE '%VP' THEN (d.salary * 1.25) ELSE (d.salary * 1.18) END) AS "sample line"
FROM (
    SELECT DISTINCT
        m.employee_id,
        m.first_name,
        m.last_name,
        m.job_id,
        m.salary
    FROM employees e
    JOIN employees m ON e.manager_id = m.employee_id
    WHERE m.job_id NOT LIKE '%PRES' 
        AND (m.salary < 6500 OR m.salary > 11500)
) d
ORDER BY d.employee_id;

--Q3

SELECT
    last_name,
    salary,
    job_id,
    NVL(TO_CHAR(manager_id), 'NONE') as manager#,
    TO_CHAR((salary*12)+ 1000, '$999,999.99') AS total_annual_pay
FROM employees
WHERE commission_pct IS NULL
    OR UPPER(job_id) LIKE 'SA%'
    AND ((salary+1000) + (salary * NVL(commission_pct,0))) > 15000
ORDER BY
    total_annual_pay DESC,
    last_name;


--Q4



--Q5



--Q6



--Q7
SELECT
    SUBSTR(UPPER(SUBSTR(first_name,0,1))||  SUBSTR(first_name, 2) || ' ' || UPPER(SUBSTR(last_name,0,1))||  SUBSTR(last_name, 2),0,24) AS full_name,
    job_id,
    LPAD(TO_CHAR(TO_CHAR(salary, '$999,999')), 15, '=') AS salary,
    department_id
FROM employees
WHERE salary + (salary * NVL(commission_pct,0)) < (
    SELECT 
        MAX(salary + (salary * NVL(commission_pct,0)))
    FROM
        employees e
    WHERE employee_id IN (
        SELECT
            employee_id
        FROM employees
        WHERE employee_id NOT IN(
            SELECT 
                m.employee_id
            FROM employees e
                JOIN employees m ON e.manager_id = m.employee_id
            UNION
            SELECT
                employee_id
            FROM employees
            WHERE job_id LIKE 'AD%'
        )
    )
)
ORDER BY
    full_name ASC;
--Q8








