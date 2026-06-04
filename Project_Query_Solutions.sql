USE emp_details;

-- View Data
SELECT * FROM Departments;
SELECT * FROM Employees;
SELECT * FROM Projects;
SELECT * FROM Timesheets;

-- 1. Find Out the Working Location of Each Employee
SELECT
e.first_name,
e.last_name,
d.location
FROM Employees e
JOIN Departments d
ON e.department_id = d.id;

-- 2. Create Salary Column & Update the Salaries for Each Department

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE Employees
ADD Salary INT;

UPDATE Employees
SET Salary =
CASE
WHEN department_id = 1 THEN 40000
WHEN department_id = 2 THEN 30000
WHEN department_id = 3 THEN 55000
WHEN department_id = 4 THEN 60000
WHEN department_id = 5 THEN 75000
WHEN department_id = 6 THEN 100000
WHEN department_id = 7 THEN 125000
WHEN department_id = 8 THEN 130000
WHEN department_id = 9 THEN 150000
END;

-- 3. Find Which Project the Employee Is Working On
SELECT
e.first_name,
p.P_name
FROM Employees e
JOIN Timesheets t
ON e.id = t.employee_id
JOIN Projects p
ON t.project_id = p.id;

-- 4. Find Out the Total Hours Worked on Each Project by Each Employee
SELECT
e.first_name,
p.P_name,
SUM(t.hours) AS total_hours
FROM Employees e
JOIN Timesheets t
ON e.id = t.employee_id
JOIN Projects p
ON t.project_id = p.id
GROUP BY
e.first_name,
p.P_name;

-- 5. Find Those Employees Who Have Not Worked on Any Projects
SELECT
e.first_name,
e.last_name
FROM Employees e
LEFT JOIN Timesheets t
ON e.id = t.employee_id
WHERE t.employee_id IS NULL;

-- 6. Find the Project with the Maximum Hours Worked
SELECT
p.P_name,
SUM(t.hours) AS total_hours
FROM Timesheets t
JOIN Projects p
ON t.project_id = p.id
GROUP BY p.P_name
ORDER BY total_hours DESC
LIMIT 1;

-- 7. Create a View That Stores Employees' Department Names & Their Respective Salaries
CREATE VIEW Employee_Department_Salary AS
SELECT
e.first_name,
d.D_name,
e.salary
FROM Employees e
JOIN Departments d
ON e.department_id = d.id;

SELECT *
FROM Employee_Department_Salary;

-- 8. Create a View That Stores the Projects Allocated to Each Employee
CREATE VIEW emp_projects AS
SELECT
e.first_name,
e.last_name AS employee_name,
p.P_name
FROM Employees e
JOIN Timesheets t
ON e.id = t.employee_id
JOIN Projects p
ON t.project_id = p.id;

-- 9. Find Employees Who Have Worked More Than 20 Hours on a Single Project
SELECT
e.first_name,
e.last_name,
t.project_id,
SUM(t.hours) AS total_hours
FROM Employees e
JOIN Timesheets t
ON e.id = t.employee_id
GROUP BY
e.id,
e.first_name,
e.last_name,
t.project_id
HAVING SUM(t.hours) > 20;

-- 10. Classify Employees Based on Their Job Titles
SELECT
CONCAT(first_name, ' ', last_name) AS employee_name,
job_title,
CASE
WHEN job_title LIKE '%Manager%' THEN 'Manager'
WHEN job_title LIKE '%Developer%' THEN 'Developer'
ELSE 'Other'
END AS role_type
FROM Employees;

-- 11. Retrieve Employees Who Worked on Multiple Projects
SELECT
CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
COUNT(DISTINCT t.project_id) AS project_count
FROM Employees e
JOIN Timesheets t
ON e.id = t.employee_id
GROUP BY
e.id,
e.first_name,
e.last_name
HAVING COUNT(DISTINCT t.project_id) > 1;

-- 12. Retrieve Each Employee’s Total Hours Worked and Show Their Rank
SELECT
CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
SUM(t.hours) AS total_hours,
RANK() OVER (
ORDER BY SUM(t.hours) DESC
) AS employee_rank
FROM Employees e
JOIN Timesheets t
ON e.id = t.employee_id
GROUP BY
e.id,
e.first_name,
e.last_name;

-- 13. List Employees Whose Total Hours Worked Are Above the Overall Average
SELECT
CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
SUM(t.hours) AS total_hours
FROM Employees e
JOIN Timesheets t
ON e.id = t.employee_id
GROUP BY
e.id,
e.first_name,
e.last_name
HAVING SUM(t.hours) >
(
SELECT AVG(total_hours)
FROM
(
SELECT
SUM(hours) AS total_hours
FROM Timesheets
GROUP BY employee_id
) temp
);

-- 14. Update Job Titles for Engineering Department Employees
-- (Except Managers and HR Specialists)

UPDATE Employees e
JOIN Departments d
ON e.department_id = d.id
SET e.job_title = 'Senior Developer'
WHERE d.D_name = 'Engineering'
AND e.job_title NOT IN ('Manager', 'HR Specialist');

-- 15. Find the Department with the Highest Average Employee Salary
SELECT
d.D_name,
AVG(e.salary) AS avg_salary
FROM Employees e
JOIN Departments d
ON e.department_id = d.id
GROUP BY d.D_name
ORDER BY avg_salary DESC
LIMIT 1;
