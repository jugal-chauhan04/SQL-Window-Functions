WITH cte1 AS
(
SELECT 
    *, 
    RANK() OVER(ORDER BY salary desc) AS highest_salary,
    RANK() OVER(ORDER BY salary asc) AS lowest_salary
FROM
    worker
)

SELECT
    worker_id,
    salary,
    department,
    CASE
        WHEN highest_salary = 1 THEN 'Highest Salary'
        ELSE 'Lowest Salary'
    END AS salary_type
FROM cte1
WHERE lowest_salary = 1 OR highest_salary = 1
