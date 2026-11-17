# Report brief

## Data source
- Platform: Databricks
- Catalog / schema: samples.bakehouse
- Tables to use:
  - sales_transactions (fact; 3,333 rows; 2024-05-01 to 2024-05-17; 48 franchises; 6 products)
  - sales_franchises (dim: name, city, country, size, supplierID, lat/long)
  - sales_customers (dim: city, state, country, continent, gender)
  - sales_suppliers (dim: ingredient, continent, approved)
  - media_customer_reviews (review text per franchise, review_date)
  - (media_gold_reviews_chunked: skip, derived text chunks)

## Business objective
- Question the report must answer: How are the bakery franchises performing on sales, and which products, locations and customer segments drive revenue?
- Decisions it should support: Which franchises/products to promote or fix, payment mix, supplier dependence per franchise.

## Audience
- Who will use it: Franchise operations / management (test audience)
- Level of detail (executive summary / analyst deep dive): Executive summary with drill-down by franchise

## KPIs
- Propose KPIs for me (e.g. total revenue, transactions, units sold, average order value, revenue by product, top franchises, payment method mix, review count)

## Filters and slicers
- Date, franchise, country, franchise size, product, payment method

## Time range and granularity
- Full available range (2024-05-01 to 2024-05-17), daily

## Branding
- Use a clean default

## Constraints
- Columns to exclude (sensitive): none (demo sample data)
- Metric definitions that must be followed: Revenue = SUM(totalPrice); totalPrice should be validated against quantity * unitPrice
- Anonymization needed? (yes/no): no (sample data)
