INSERT INTO customers (CustomerID, Country)
SELECT DISTINCT CustomerID, 
	   MODE() WITHIN GROUP (ORDER BY Country) AS Country
FROM staging_online_retail
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
;

-- is_real_product is to identify real products and not admin code (POST, DOT, M, etc.)
-- UPPER(StockCode) to solve problem with 2 identical StockCode but different case: 15056bl and 15056BL
INSERT INTO products (StockCode, Description, is_real_product)
SELECT UPPER(StockCode) AS StockCode, 
	   MODE() WITHIN GROUP (ORDER BY Description) AS Description,
	   CASE WHEN UPPER(StockCode) ~ '^[0-9]' THEN TRUE
	   ELSE FALSE
	   END AS is_real_product
FROM staging_online_retail
GROUP BY UPPER(StockCode)
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
	   UPPER(StockCode) AS StockCode,
	   CustomerID,
	   InvoiceDate::date AS InvoiceDate,
	   Quantity,
	   UnitPrice,
	   CASE
	   		WHEN quantity < 0 THEN TRUE
			ELSE FALSE
	   END AS is_cancelled
FROM staging_online_retail
WHERE InvoiceNo IS NOT NULL
AND StockCode IS NOT NULL
AND InvoiceDate IS NOT NULL
;