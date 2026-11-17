USE northwind;


SELECT 
    c.company_name AS customer_name,
    SUM((od.unit_price * od.quantity) * (1 - od.discount)) AS total_order_value,
    RANK() OVER (ORDER BY SUM((od.unit_price * od.quantity) * (1 - od.discount)) DESC) AS customer_rank
FROM dbo.customers c
JOIN dbo.orders o ON c.customer_id = o.customer_id
JOIN dbo.order_details od ON o.order_id = od.order_id
GROUP BY c.company_name;


WITH RankedProducts AS (
    SELECT 
        cat.category_name,
        p.product_name,
        p.unit_price,
        DENSE_RANK() OVER (PARTITION BY cat.category_id ORDER BY p.unit_price DESC) as price_rank
    FROM dbo.products p
    JOIN dbo.categories cat ON p.category_id = cat.category_id
)
SELECT category_name, product_name, unit_price
FROM RankedProducts
WHERE price_rank = 2;


WITH EmployeeSales AS (
    SELECT 
        e.employee_id,
        e.first_name + ' ' + e.last_name AS employee_name,
        o.order_date,
        SUM((od.unit_price * od.quantity) * (1 - od.discount)) AS order_sales
    FROM dbo.employees e
    JOIN dbo.orders o ON e.employee_id = o.employee_id
    JOIN dbo.order_details od ON o.order_id = od.order_id
    GROUP BY e.employee_id, e.first_name, e.last_name, o.order_date
)
SELECT 
    employee_name,
    order_date,
    order_sales,
    SUM(order_sales) OVER (PARTITION BY employee_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM EmployeeSales;


WITH OrderValues AS (
    SELECT 
        o.employee_id,
        o.order_id,
        SUM((od.unit_price * od.quantity) * (1 - od.discount)) AS order_val
    FROM dbo.orders o
    JOIN dbo.order_details od ON o.order_id = od.order_id
    GROUP BY o.employee_id, o.order_id
),
EmpAvg AS (
    SELECT employee_id, AVG(order_val) AS avg_emp_order FROM OrderValues GROUP BY employee_id
)
SELECT 
    e.first_name + ' ' + e.last_name AS employee_name,
    ea.avg_emp_order
FROM EmpAvg ea
JOIN dbo.employees e ON ea.employee_id = e.employee_id
WHERE ea.avg_emp_order > (SELECT AVG(order_val) FROM OrderValues);


WITH YearlyEmpOrders AS (
    SELECT 
        YEAR(o.order_date) AS order_year,
        e.employee_id,
        e.first_name + ' ' + e.last_name AS employee_name,
        COUNT(o.order_id) AS total_orders,
        ROW_NUMBER() OVER (PARTITION BY YEAR(o.order_date) ORDER BY COUNT(o.order_id) DESC) as rn
    FROM dbo.orders o
    JOIN dbo.employees e ON o.employee_id = e.employee_id
    GROUP BY YEAR(o.order_date), e.employee_id, e.first_name, e.last_name
)
SELECT order_year, employee_name, total_orders
FROM YearlyEmpOrders
WHERE rn = 1;


WITH RankedCategoryProducts AS (
    SELECT 
        cat.category_name,
        p.product_name,
        p.unit_price,
        ROW_NUMBER() OVER (PARTITION BY cat.category_id ORDER BY p.unit_price DESC) as rn
    FROM dbo.products p
    JOIN dbo.categories cat ON p.category_id = cat.category_id
)
SELECT category_name, product_name, unit_price
FROM RankedCategoryProducts
WHERE rn <= 3;


WITH CategoryProductSales AS (
    SELECT 
        cat.category_name,
        p.product_name,
        SUM((od.unit_price * od.quantity) * (1 - od.discount)) AS total_sales
    FROM dbo.products p
    JOIN dbo.categories cat ON p.category_id = cat.category_id
    JOIN dbo.order_details od ON p.product_id = od.product_id
    GROUP BY cat.category_name, p.product_name
)
SELECT 
    category_name,
    product_name,
    total_sales,
    RANK() OVER (PARTITION BY category_name ORDER BY total_sales DESC) AS sales_rank
FROM CategoryProductSales;


WITH EmployeeOrders AS (
    SELECT 
        o.employee_id,
        o.order_id,
        SUM((od.unit_price * od.quantity) * (1 - od.discount)) AS order_val,
        ROW_NUMBER() OVER (PARTITION BY o.employee_id ORDER BY SUM((od.unit_price * od.quantity) * (1 - od.discount)) DESC) as rn
    FROM dbo.orders o
    JOIN dbo.order_details od ON o.order_id = od.order_id
    GROUP BY o.employee_id, o.order_id
)
SELECT 
    e.first_name + ' ' + e.last_name AS employee_name,
    eo.order_id,
    eo.order_val AS highest_order_value
FROM EmployeeOrders eo
JOIN dbo.employees e ON eo.employee_id = e.employee_id
WHERE eo.rn = 1;


WITH CategorySales AS (
    SELECT 
        cat.category_name,
        SUM((od.unit_price * od.quantity) * (1 - od.discount)) AS cat_sales
    FROM dbo.categories cat
    JOIN dbo.products p ON cat.category_id = p.category_id
    JOIN dbo.order_details od ON p.product_id = od.product_id
    GROUP BY cat.category_name
)
SELECT 
    category_name,
    cat_sales,
    (cat_sales * 100.0 / SUM(cat_sales) OVER()) AS percentage_of_total_sales
FROM CategorySales;


WITH CustomerTotals AS (
    SELECT 
        c.customer_id,
        c.company_name,
        SUM((od.unit_price * od.quantity) * (1 - od.discount)) AS total_val
    FROM dbo.customers c
    JOIN dbo.orders o ON c.customer_id = o.customer_id
    JOIN dbo.order_details od ON o.order_id = od.order_id
    GROUP BY c.customer_id, c.company_name
)
SELECT company_name, total_val
FROM CustomerTotals
WHERE total_val > (SELECT AVG(total_val) FROM CustomerTotals);


SELECT product_id, product_name
FROM dbo.products
WHERE product_id NOT IN (SELECT DISTINCT product_id FROM dbo.order_details);


SELECT 
    e.first_name + ' ' + e.last_name AS employee_name,
    YEAR(o.order_date) AS sales_year,
    SUM((od.unit_price * od.quantity) * (1 - od.discount)) AS total_sales
FROM dbo.employees e
JOIN dbo.orders o ON e.employee_id = o.employee_id
JOIN dbo.order_details od ON o.order_id = od.order_id
GROUP BY e.employee_id, e.first_name, e.last_name, YEAR(o.order_date);
GO