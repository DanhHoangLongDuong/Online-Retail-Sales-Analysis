\# Online Retail Sales Analysis - SQL + Power BI

Data cleaning, star-schema modeling, and RFM customer segmentation on a messy, real-world e-commerce dataset.



!\[overview](images/overview\_page.png)



\## Project Overview

Analysis of \~540,000 transactions from a UK-based online gift retailer (Dec 2010 - Dec 2011).

\[dataset source](https://www.kaggle.com/datasets/tunguz/online-retail)



Unlike a lot of Kaggle datasets, this one is messy - inconsistent product codes, \~25% missing customer IDs, administrative line items mixed in with real products, and ambiguous cancellation data. 

The project covers the full pipeline: staging and cleaning the raw data in PostgreSQL, modeling it into a star schema, and building a 3-page Power BI dashboard with DAX-driven KPIs and an RFM customer segmentation.



\## Tech Stack

\- \*\*PostgreSQL\*\* - staging, cleaning, and star-schema modeling

\- \*\*Power BI\*\* - data model, DAX measures, dashboard

\- \*\*SQL\*\* - window functions, CTEs, views



\## Key Findings

\- \*\*Revenue is concentrated in a small group of customers\*\*. Customers scored "high priority" by the RFM model make up around 11% of the customer base, but generate more total revenue than the "low priority" segment - nearly 3x its size - combined. (See Customers % RFM page)

\- \*\*RFM catches what a simple revenue ranking misses.\*\* Customer 12346 spent £77,183 - enough to rank in the top 10 by revenue alone - but it came from a single order placed 325 days ago. RFM correctly scores this customer as medium priority despite the high lifetime spend,

which a naive "sort by total revenue" approach would have missed entirely.

!\[12346](images/customer12346.png)

\- \*\*Strong seasonality\*\*, consistent with a gift retailer: revenue climbs through Q4, peaking in November, then drops sharply in December as the ordering window for Christmas delivery closes.

\- \*\*The UK accounts for the large majority of revenue\*\*, with the Netherlands, Ireland, Germany, and France as distant next-largest markets.



\## Data Cleaning Highlights

The raw data required more than a straightforward import. Some of the issues found and how they were handled:



| Issue | Fix |

|---|---|

|Same product stored as `15056bl` and `15056BL`|Normalized all `StockCode` values to uppercase|

|Administrative line items (`POST`, `DOT`, `M`, `BANK CHARGES`, `CRUK`, `C2`, `AMAZONFEE`) mixed into product data|Built a regex-based `is\_real\_product` flag (numeric-first codes only) instead of a hardcoded exclusion list|

|\~25% of rows missing `CustomerID`|Kept in the fact table - it is still real revenue, just excluded from customer-level analysis (RFM, country-by-customer)|

|Some negative-quantity rows were not `C` - prefixed cancellations|Investigated a sample (null `CustomerID`, £0 price, large round quantities - consistent with inventory write-offs, not customer returns) and made the documented call to treat any negative quantity as excluded, since intent could 

not be reliably distinguished from the data alone|

|Duplicate/near-duplicate product descriptions per `StockCode`|Resolved with `MODE()` - kept the most frequently occurring description per code|



Full cleaning logic is in \[sql/transform.sql](sql/transform.sql)



\## Data Model



!\[relationship](images/relationships.png)



A star schema with `orders` as the fact table, and `customers`, `products`, and `dim\_date` as dimensions. `customer\_rfm` sits as an outrigger off `customers` - a SQL `VIEW` holding pre-computed recency/frequency/monetary scores and a priority label, refreshed independently of the fact table.



\## Dashboard

\### Overview

!\[overview](images/overview\_page.png)



Headline KPIs (£10.64M net revenue, £513.54 average order value, 4.3K customers, 1.96% cancellation rate), a monthly revenue trend, top 5 countries by revenue, and a cancellation rate trend for comparison.



\### Product Performance

!\[product\_performance](images/product\_performance.png)



Top 10 products by revenue and by quantity (note: these two ranking do not fully overlap) - e.g. "Regency Cakestand 3 Tier" leads by revenue while "Paper Craft, Little Birdie" leads by quantity), a revenue-vs-quantity scatter plot, and a cancellation-rate table restricted to products

with 3+ orders to avoid small-sample distortion.



\### Customers \& RFM

!\[Customers](images/Customers.png)



Priority segment distribution, revenue by segment, a recency-vs-revenue scatter colored by priority, and a top 10 customers table with the underlying RFM inputs visible alongside each customer's label.



\## How to Reproduce

1\. Download the dataset from \[Kaggle](https://www.kaggle.com/datasets/tunguz/online-retail) and place the CSV in `data/`

2\. Run `sql/schema.sql`

3\. Load the CSV into staging:

```

&#x20; psql -U postgres -d online\_retail -f sql/load.sql

```

4\. Run `sql/transform.sql`

5\. Run `sql/analysis.sql`

6\. Open `powerbi/online\_retail\_report.pbix` in Power BI Desktop and point the PostgreSQL connection at your local database



\## Project Structure



```

online-retail-sql-powerbi/

├── README.md

├── .gitignore

├── data/                          (gitignored — see step 1 above)

├── sql/

│   ├── schema.sql

│   ├── load.sql

│   ├── transform.sql

│   └── analysis.sql

├── powerbi/

│   └── online\_retail\_report.pbix

└── images/

&#x20;   ├── overview.png

&#x20;   ├── product\_performance.png

&#x20;   ├── customers.png

&#x20;   └── relationships.png

```



\## Author

\*\*Long\*\*



