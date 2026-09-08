-- Run in terminal: psql -U postgres -d online_retail -f sql/load.sql
\copy staging_online_retail FROM 'data/Online_Retail.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'LATIN1');