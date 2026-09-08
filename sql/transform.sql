INSERT INTO customers (CustomerID, Country)
SELECT DISTINCT CustomerID, 
	   MODE() WITHIN GROUP (ORDER BY Country) AS Country
FROM staging_online_retail
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
;

-- is_real_product is to identify real products and not admin code (POST, DOT, M, etc.)
INSERT INTO products (StockCode, Description, is_real_product)
SELECT StockCode, 
	   MODE() WITHIN GROUP (ORDER BY Description) AS Description,
	   CASE WHEN StockCode ~ '^[0-9]' THEN TRUE
	   ELSE FALSE
	   END AS is_real_product
FROM staging_online_retail
GROUP BY StockCode
;

INSERT INTO dim_date (date_key, year, quarter, month, month_name, day_of_week)
SELECT DISTINCT InvoiceDate::date AS date_key,
	   EXTRACT(YEAR FROM InvoiceDate) AS year,
	   EXTRACT(QUARTER FROM InvoiceDate) AS quarter,
	   EXTRACT(MONTH FROM InvoiceDate) AS month,
	   TO_CHAR(InvoiceDate, 'Month') AS month_name,
	   TO_CHAR(InvoiceDate, 'Day') AS day_of_week
FROM staging_online_retail
WHERE InvoiceDate IS NOT NULL
;

--is_cancelled is to identify cancelled orders
INSERT INTO orders (InvoiceNo, StockCode, CustomerID, InvoiceDate, Quantity, UnitPrice, is_cancelled)
SELECT InvoiceNo,
	   StockCode,
	   CustomerID,
	   InvoiceDate,
	   Quantity,
	   UnitPrice,
	   CASE
	   		WHEN InvoiceNo LIKE 'C%' THEN TRUE
			ELSE FALSE
	   END AS is_cancelled
FROM staging_online_retail
WHERE InvoiceNo IS NOT NULL
AND StockCode IS NOT NULL
AND InvoiceDate IS NOT NULL
;