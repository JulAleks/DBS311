/***********************************
Assignment 1 - DBS 311
Julia Alekssev, 051292134
Ka Ying Chan, 123231227
Audrey Duzon, 019153147
2023-10-06 <<================== UPDATE DATE!
**********************************/

-- Q1
SELECT 
    employee_id,
  --  SUBSTR( UPPER(SUBSTR(last_name,0,1)) || SUBSTR(last_name, 2) || ', ' || UPPER(SUBSTR(first_name,0,1))|| SUBSTR(first_name, 2), 0,25) AS full_name, 
  --  SUBSTR(last_name || ', ' || first_name, 1, 25) AS Fullname, -- Nicole: I think we might not need rpad(25) as padding 25 characters is not required, we only need to limit the word count of fullname
      SUBSTR(INITCAP(last_name) || ', ' || INITCAP(first_name), 1, 25) AS Fullname,   --Julia: I think this should be ok, i added something becasue the lower case if bruce pissed my OCD off
    job_id,
    TO_CHAR(LAST_DAY(hire_date), '[Month ddth "of" YYYY]') AS "Start Date"
FROM employees
WHERE
    EXTRACT(MONTH FROM hire_date) IN (5, 11) AND
    EXTRACT(YEAR FROM hire_date) NOT IN ('2015', '2016')
ORDER BY
    hire_date DESC;

---------------------------------------------------------------------------------------------------
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
        m.salary,
        TO_CHAR(m.salary, '$999,999.99') AS total_annual_pay
    FROM employees e
    JOIN employees m ON e.manager_id = m.employee_id
    WHERE m.job_id NOT LIKE '%PRES' 
        AND (m.salary < 6500 OR m.salary > 11500)
) d
--ORDER BY d.employee_id;
--sort by top salaries first
ORDER BY 
    salary DESC;


-- Q2 Original Modified:                WE CAN'T USE ID CASE IF IN THIS ASS 
--SELECT
--    'Emp# ' || employee_id || ' named ' || first_name || ' ' || last_name || ' who is ' || job_id || ' will have a new salary of $' || 
--    (CASE 
--        WHEN UPPER(job_id) LIKE '%VP' THEN (salary * 1.25) -- TO UPPER     //CLINT SAID WE CANNOT USE CASE 
--        ELSE (salary * 1.18) 
--    END) AS "Employees with increased Pay"
--FROM (
--    SELECT DISTINCT
--        m.employee_id,
--        m.first_name,
--        m.last_name,
--        m.job_id,
--        m.salary
--        -- TO_CHAR(m.salary, '$999,999.99') AS total_annual_pay -- NOT USED
--    FROM employees e
--        JOIN employees m ON e.manager_id = m.employee_id
--    WHERE m.job_id NOT LIKE '%PRES' 
--        AND (m.salary <= 6500 OR m.salary >= 11500) -- SHOULD BE >= AND <=
--    ) -- Alias 'd' not needed
--ORDER BY 
--    salary DESC;
    
-- OR -- Nicole
--SELECT 
--    'Emp# ' || employee_id || ' named ' || first_name || ' ' || last_name || ' who is ' || job_id || ' will have a new salary of $' || 
--    CASE 
--        WHEN UPPER(job_id) LIKE '%VP%' THEN ROUND(salary * 1.25, 2) 
--        ELSE ROUND(salary * 1.18, 2) 
--    END AS "Employees with increased Pay"
--FROM employees 
--WHERE 
--    (salary <= 6500 OR salary >= 11500) AND
--    (UPPER(job_id) LIKE '%VP%' OR UPPER(job_id) LIKE '%MAN%' OR UPPER(job_id) LIKE '%MGR%') AND
--    UPPER(job_id) NOT LIKE '%PRES%'
--ORDER BY salary DESC;

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
    (commission_pct IS NULL OR department_id = 80) AND
    (salary + (salary * NVL(commission_pct, 0)) + 1000) > 15000
ORDER BY "Total Income" DESC;

---------------------------------------------------------------------------------------------------
--Q4
SELECT
    e.department_id, 
    d.department_name,
    e.employee_id, 
    e.job_id,
    TO_CHAR(MIN(e.salary), '$999,999.99')AS "Lowest Dept/Job Pay"
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.job_id NOT LIKE 'IT%' AND e.job_id NOT LIKE '%REP' AND e.job_id NOT LIKE 'SA%'
GROUP BY 
    e.department_id, e.employee_id, e.job_id, d.department_name
HAVING 
    MIN(e.salary) BETWEEN 6500 AND 16800
ORDER BY 
    e.department_id, 
    e.job_id;

---------------------------------------------------------------------------------------------------
--Q5 [CANNOT / NEED TO ASK PROF.]
SELECT 
    last_name,
    salary,
    job_id
FROM employees e1
    LEFT JOIN departments d ON e1.department_id = d.department_id
    LEFT JOIN locations l ON d.location_id = l.location_id
    LEFT JOIN countries c ON l.country_id = c.country_id -- ENSURE SELECTING ALL EMPS
WHERE salary*(1+NVL(commission_pct,0)) NOT IN ( -- INVERSE SELECTION: NOT LOWEST PAID.
    SELECT MIN(salary*(1+NVL(commission_pct,0))) AS "MIN-PAID"
    FROM employees e2
    WHERE e1.department_id = e2.department_id
    GROUP BY department_id
    ) 
    AND UPPER(e1.job_id) NOT IN ('AD_PRES', 'AD_VP')
    AND UPPER(c.country_id) NOT IN ('US')
ORDER BY JOB_ID;
-- US: 
-- = location_id IN (1700, 1600, 1500, 1400)
-- = department_id IN (10, 50, 60, 90, 110, 190)
-- ANS WILL ONLY INCLUDE DEPARTMENT IN (20, 80)
-- Dept 80 staff: Zlotkey, Abel (Exclude LOWEST PAID EMP: Taylor)
-- Dept 20 staff: Hartstein (Exclude LOWEST PAID EMP: Fay)
-- O/P:
-- Hartstein, Zlotkey, Abel

-- Expected output also with employee_id: 103 and 205 (CANNOT)

--Audrey q5 showing all employees earnign more than 10320 (highest pay amongth lowest= 6000, 10320)
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
        FROM(
            SELECT 
                MIN(salary + (NVL(commission_pct,0)* salary)) salary,
                department_id
            FROM employees
            WHERE department_id IN (
                SELECT
                    d.department_id
                FROM departments d
                    JOIN locations l ON d.location_id = l.location_id
                    JOIN countries c ON l.country_id = c.country_id
                WHERE c.country_id != 'US'
            )
            GROUP BY department_id
        )
    )
ORDER BY job_id;
--hunold not included since he earns only 9000 which is less than 10320 
--taylor not included since he earnes exactly 10320 which is exact

--audrey opt 2 
--output from the lowest paid employee ever, salary 6000, hunold included since he earns more than 6000
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
            SELECT MIN(salary) 
        FROM(
            SELECT 
                MIN(salary + (NVL(commission_pct,0)* salary)) salary,
                department_id
            FROM employees
            WHERE department_id IN (
                SELECT
                    d.department_id
                FROM departments d
                    JOIN locations l ON d.location_id = l.location_id
                    JOIN countries c ON l.country_id = c.country_id
                WHERE c.country_id != 'US'
            )
            GROUP BY department_id
        )
    )
ORDER BY job_id
;


--without comission
--final output 4, HIGHEST SAL AMONG LOWESTIS 10320
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
    AND salary > (
            SELECT MAX(salary) 
        FROM(
            SELECT 
                MIN(salary) salary,
                department_id
            FROM employees
            WHERE department_id IN (
                SELECT
                    d.department_id
                FROM departments d
                    JOIN locations l ON d.location_id = l.location_id
                    JOIN countries c ON l.country_id = c.country_id
                WHERE c.country_id != 'US'
            )
            GROUP BY department_id
        )
    )
ORDER BY job_id;

-- Q6
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

SELECT 
    COALESCE(d.department_name, 'Not Assigned Yet') AS Department,
    COALESCE(SUBSTR(l.city, 1, 22), 'Not Assigned Yet') AS City,
    COALESCE(e.job_id, 'No employees') AS Department,
    COUNT(DISTINCT e.job_id) AS "# of Jobs"
FROM
    employees e
FULL OUTER JOIN
    departments d ON e.department_id = d.department_id
FULL OUTER JOIN
    locations l ON d.location_id = l.location_id
GROUP BY
    COALESCE(d.department_name, 'Not Assigned Yet'),
    COALESCE(SUBSTR(l.city, 1, 22), 'Not Assigned Yet'),
    COALESCE(e.job_id, 'No employees')
ORDER BY
"# of Jobs",
    COALESCE(d.department_name, 'Not Assigned Yet'),
    City;

