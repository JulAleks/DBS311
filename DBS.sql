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






