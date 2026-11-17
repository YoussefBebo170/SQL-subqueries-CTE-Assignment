Use RouteAcademyDB;


SELECT c.company_name, AVG(i.price) AS average_price
FROM company c
JOIN items i ON c.company_id = i.company_id
GROUP BY c.company_id, c.company_name;


SELECT c.company_name, AVG(i.price) AS average_price
FROM company c
JOIN items i ON c.company_id = i.company_id
GROUP BY c.company_id, c.company_name
HAVING AVG(i.price) > (SELECT AVG(price) FROM items);


SELECT item_id, item_name, price, company_id
FROM items
WHERE price > (SELECT AVG(price) FROM items);


SELECT emp_id, emp_fname, emp_lname, emp_dept AS dept_code
FROM employees
WHERE emp_dept IN (
    SELECT dept_code 
    FROM departments 
    WHERE dept_budget > (SELECT AVG(dept_budget) FROM departments)
);


SELECT d.dept_code, d.dept_name
FROM departments d
JOIN employees e ON d.dept_code = e.emp_dept
GROUP BY d.dept_code, d.dept_name
HAVING COUNT(e.emp_id) > (
    SELECT AVG(emp_count) 
    FROM (
        SELECT COUNT(emp_id) AS emp_count 
        FROM employees 
        GROUP BY emp_dept
    ) AS sub
);


SELECT i1.item_id, i1.item_name, i1.price, i1.company_id
FROM items i1
WHERE i1.price < (
    SELECT AVG(i2.price)
    FROM items i2
    WHERE i2.company_id = i1.company_id
);


SELECT d.dept_code, d.dept_name, COUNT(e.emp_id) AS count_of_employees
FROM departments d
JOIN employees e ON d.dept_code = e.emp_dept
GROUP BY d.dept_code, d.dept_name
HAVING COUNT(e.emp_id) = 1;


SELECT c.company_name, AVG(i.price) AS average_price
FROM company c
JOIN items i ON c.company_id = i.company_id
GROUP BY c.company_id, c.company_name
HAVING AVG(i.price) = (
    SELECT MIN(avg_price)
    FROM (
        SELECT AVG(price) AS avg_price
        FROM items
        GROUP BY company_id
    ) AS sub
);


SELECT emp_id, emp_fname, emp_lname, emp_dept AS dept_code
FROM employees
WHERE emp_dept IN (
    SELECT dept_code 
    FROM departments 
    WHERE dept_budget < (SELECT AVG(dept_budget) FROM departments)
);


WITH AvgPriceCTE AS (
    SELECT AVG(price) AS overall_avg FROM items
)
SELECT item_id, item_name, price, company_id
FROM items, AvgPriceCTE
WHERE price > overall_avg;


WITH ItemCountCTE AS (
    SELECT company_id, COUNT(item_id) AS item_count
    FROM items
    GROUP BY company_id
)
SELECT c.company_name, ic.item_count
FROM company c
JOIN ItemCountCTE ic ON c.company_id = ic.company_id;


WITH CompAvgPriceCTE AS (
    SELECT company_id, AVG(price) AS avg_price
    FROM items
    GROUP BY company_id
)
SELECT c.company_name, cap.avg_price
FROM company c
JOIN CompAvgPriceCTE cap ON c.company_id = cap.company_id
WHERE cap.avg_price > 2000;


WITH EmpDeptCTE AS (
    SELECT e.emp_fname + ' ' + e.emp_lname AS full_name, d.dept_name
    FROM employees e
    JOIN departments d ON e.emp_dept = d.dept_code
)
SELECT full_name, dept_name
FROM EmpDeptCTE;


WITH AvgBudgetCTE AS (
    SELECT AVG(dept_budget) AS overall_avg_budget FROM departments
)
SELECT dept_code, dept_name, dept_budget
FROM departments, AvgBudgetCTE
WHERE dept_budget > overall_avg_budget;


WITH DeptEmpCountCTE AS (
    SELECT emp_dept, COUNT(emp_id) AS emp_count
    FROM employees
    GROUP BY emp_dept
)
SELECT d.dept_code, d.dept_name, dec.emp_count
FROM departments d
JOIN DeptEmpCountCTE dec ON d.dept_code = dec.emp_dept
WHERE dec.emp_count > 1;


WITH CompanyAvgCTE AS (
    SELECT company_id, AVG(price) AS comp_avg
    FROM items
    GROUP BY company_id
),
OverallAvgCTE AS (
    SELECT AVG(price) AS overall_avg FROM items
)
SELECT c.company_name, ca.comp_avg
FROM company c
JOIN CompanyAvgCTE ca ON c.company_id = ca.company_id
CROSS JOIN OverallAvgCTE oa
WHERE ca.comp_avg < oa.overall_avg;