INSERT INTO customers (CustomerID, Country)
SELECT DISTINCT CustomerID, 
	   MODE() WITHIN GROUP (ORDER BY Country) AS Country
FROM staging_online_retail
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
;

INSERT INTO products (StockCode, Description)
SELECT StockCode, 
	   MODE() WITHIN GROUP (ORDER BY Description) AS Description
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