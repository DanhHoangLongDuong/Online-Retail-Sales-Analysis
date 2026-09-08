CREATE TABLE staging_online_retail (
	InvoiceNo VARCHAR(10),
	StockCode VARCHAR(20),
	Description TEXT,
	Quantity INTEGER,
	InvoiceDate TIMESTAMP,
	UnitPrice NUMERIC(10, 2),
	CustomerID INTEGER,
	Country VARCHAR(30)
);

CREATE TABLE customers(
	CustomerID INTEGER PRIMARY KEY,
	Country VARCHAR(20)
);

CREATE TABLE products(
	StockCode VARCHAR(20) PRIMARY KEY,
	Description TEXT
);

CREATE TABLE dim_date(
	date_key DATE PRIMARY KEY,
	year INTEGER,
	quarter INTEGER,
	month INTEGER,
	month_name VARCHAR(10),
	day_of_week VARCHAR(10)
);

CREATE TABLE orders(
	order_line_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	InvoiceNo VARCHAR(10) NOT NULL,
	StockCode VARCHAR(20) NOT NULL REFERENCES products(StockCode),
	CustomerID INTEGER REFERENCES customers(CustomerID),
	InvoiceDate TIMESTAMP NOT NULL,
	Quantity INTEGER,
	UnitPrice NUMERIC(10, 2),
	is_cancelled BOOLEAN
);