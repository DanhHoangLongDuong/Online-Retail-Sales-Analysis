-- Total Net Revenue
SELECT SUM(unitprice * quantity)
FROM orders
WHERE is_cancelled = FALSE
;

-- Revenue by month
WITH revenue_by_month AS (
	SELECT TO_CHAR(InvoiceDate, 'YYYY-MM') AS yearAndMonth,
		   UnitPrice,
		   quantity,
		   is_cancelled
	FROM orders
)
SELECT yearAndMonth,
	   SUM(UnitPrice * quantity) AS total_revenue
FROM revenue_by_month
WHERE is_cancelled = FALSE
GROUP BY yearAndMonth
ORDER BY yearAndMonth ASC
;

-- Top 10 products by revenue
SELECT orders.StockCode,
	   description,
	   SUM(UnitPrice * quantity) AS total_revenue
FROM orders
INNER JOIN products
ON orders.stockCode = products.StockCode
WHERE is_real_product = TRUE
AND is_cancelled = FALSE
GROUP BY orders.StockCode, description
ORDER BY total_revenue DESC
LIMIT 10;

-- Top 10 products by quantity sold
SELECT orders.StockCode,
	   description,
	   SUM(quantity) AS total_quantity
FROM orders
INNER JOIN products
ON orders.StockCode = products.StockCode
WHERE is_real_product = TRUE
AND is_cancelled = FALSE
GROUP BY orders.StockCode, description
ORDER BY total_quantity DESC
LIMIT 10;

-- Top countries by revenue
SELECT country,
	   SUM(unitprice * quantity) AS total_revenue
FROM orders
INNER JOIN customers
ON orders.CustomerID = customers.CustomerID
WHERE is_cancelled = FALSE
GROUP BY country
ORDER BY total_revenue DESC;

-- Average order value
SELECT SUM(unitprice * quantity) / COUNT(DISTINCT InvoiceNo) AS average_value
FROM orders
WHERE is_cancelled = FALSE;

-- Cancellation rate
SELECT COUNT(is_cancelled) * 100.0 / (SELECT COUNT(*) FROM orders)  AS cancellation_rate
FROM orders 
WHERE is_cancelled = TRUE;

-- RFM
CREATE VIEW customer_rfm AS
--Recency
WITH recency_table AS (
SELECT CustomerID,
	   (SELECT MAX(InvoiceDate) FROM orders) - MAX(InvoiceDate) AS recent_order,
	   NTILE(4) OVER(ORDER BY (SELECT MAX(InvoiceDate) FROM orders) - MAX(InvoiceDate) ASC) AS recency_quartile
FROM orders
WHERE CustomerID IS NOT NULL
AND is_cancelled = FALSE
GROUP BY CustomerID
),

--Frequency
frequency_table AS (
SELECT CustomerID, 
	   COUNT(DISTINCT InvoiceNo) AS total_orders,
	   NTILE(4) OVER(ORDER BY COUNT(DISTINCT InvoiceNo) DESC) AS frequency_quartile
FROM orders
WHERE CustomerID IS NOT NULL
AND is_cancelled = FALSE
GROUP BY CustomerID
),

-- Monetary
monetary_table AS (
SELECT CustomerID,
	   SUM(UnitPrice * quantity) AS total_revenue,
	   NTILE(4) OVER(ORDER BY SUM(UnitPrice * quantity) DESC) AS monetary_quartile
FROM orders
WHERE CustomerID IS NOT NULL
AND is_cancelled = FALSE
GROUP BY CustomerID
)

SELECT rt.CustomerID,
	   recent_order,
	   total_orders,
	   total_revenue,
	   CASE 
	   		WHEN ((recency_quartile+frequency_quartile+monetary_quartile) / 3.0) = 1 THEN 'high'
			WHEN ((recency_quartile+frequency_quartile+monetary_quartile) / 3.0) BETWEEN 1 AND 2 THEN 'medium'
			ELSE 'low'
			END AS priority
FROM recency_table rt
INNER JOIN frequency_table ft
ON rt.CustomerID = ft.CustomerID
INNER JOIN monetary_table mt
ON rt.CustomerID = mt.CustomerID
;



