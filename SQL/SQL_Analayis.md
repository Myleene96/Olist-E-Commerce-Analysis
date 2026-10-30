# Olist E-Commerce SQL Analysis

This document explains the SQL analysis of the Olist Brazilian e-commerce dataset, including database preparation, business questions, key findings, and recommendations.

**Tool:** MySQL

## 1. Project Goal

Use SQL to analyze e-commerce order data, identify business trends, and develop actionable recommendations.

The analysis focuses on five key questions:

- **Business Performance:** How are revenue, order volume, and customer numbers performing?
- **Product and Category Performance:** Which products and categories generate the most revenue?
- **Regional Performance:** Which states contribute the most to revenue?
- **Customer Retention:** Do customers return to make repeat purchases?
- **Delivery and Customer Satisfaction:** How well are orders delivered, and how is delivery performance related to customer reviews?

## 2. Dataset

**Source:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The dataset contains information about orders, customers, products, sellers, payments, and customer reviews from a Brazilian e-commerce marketplace.

### 2.1 Database Tables

| Table | Contents | Primary Key |
|---|---|---|
| `orders` | Order status and dates | `order_id` |
| `order_items` | Products, sellers, price, and freight per order | `order_id` + `order_item_id` |
| `payments` | Payment type, installments, and value | `order_id` + `payment_sequential` |
| `customers` | Customer ID and location | `customer_id` |
| `products_cleaned` | Product and category information | `product_id` |
| `reviews` | Review scores | `review_id` + `order_id` |
| `sellers` | Seller location | `seller_id` |
| `category_translation` | Portuguese-to-English category names | `product_category_name` |

### 2.2 Database Relationships

The tables are connected through shared identifiers, allowing data to be combined for analysis using SQL joins.

| Child Table | Column | Parent Table |
|---|---|---|
| `orders` | `customer_id` | `customers` |
| `order_items` | `order_id` | `orders` |
| `order_items` | `product_id` | `products_cleaned` |
| `order_items` | `seller_id` | `sellers` |
| `payments` | `order_id` | `orders` |
| `reviews` | `order_id` | `orders` |
| `products_cleaned` | `product_category_name` | `category_translation` |

### 2.3 Customer Identification

The analysis uses `customer_unique_id` to identify individual customers because `customer_id` can change between orders made by the same customer.

This distinction is important when calculating unique customers and repeat-purchase rates.

## 3. Data Preparation

### 3.1 Missing Values

| Table | Issue | Handling |
|---|---|---|
| `orders` | Missing delivery dates: 160 for approval, 1,783 for carrier, and 2,965 for customer | Converted empty strings to `NULL`. Kept these records because the orders were not delivered. Delivery analysis includes only delivered orders with a recorded delivery date. |
| `products` → `products_cleaned` | 610 products had missing values in category, name length, description length, or photo count | Created `products_cleaned` from the original table. Missing categories were labeled `unknown`. Missing photo counts were kept as `NULL`, not `0`. Six unused columns were dropped: name length, description length, weight, and three size columns. No other blank values or duplicate IDs remained. |
| `reviews` | 87,656 missing comment titles and 58,247 missing comment texts | Free-text columns were not loaded because only review scores were used in the analysis. |
| `customers`, `order_items`, `payments`, `sellers`, `category_translation` | No missing values | No cleaning required. |
| `orders` | 8 orders marked "delivered" have no delivery date | Excluded from delivery and late-delivery analysis, because lateness cannot be measured | 
| `orders` | Delivery dates missing: 160 approval, 1,783 carrier, 2,965 customer | Empty strings converted to NULL. Kept, because these orders were not delivered. Delivery analysis uses delivered orders with a date only |


# Olist E-Commerce Data Analysis

## Project Overview

This project analyzes the Brazilian Olist e-commerce dataset to understand business performance, customer behavior, product sales, payment preferences, delivery efficiency, and customer satisfaction.

Using data analysis tools, the project aims to turn raw e-commerce data into actionable business insights and recommendations.

## Project Objectives

- Evaluate sales performance through revenue, order volume, and customer metrics.
- Identify top-performing product categories and revenue-generating regions.
- Analyze customer retention and repeat-purchase behavior.
- Examine payment methods and installment preferences.
- Evaluate delivery performance and its relationship with customer reviews.
- Develop data-driven recommendations to support business decisions.

## Dataset

**Source:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The dataset contains information about orders, customers, products, sellers, payments, and customer reviews from a Brazilian e-commerce marketplace.

## Tools and Technologies

- **SQL (MySQL):** Data querying, KPI calculations, and business analysis.
- **Python:** Data cleaning, exploratory data analysis (EDA), and visualization.
- **Tableau:** Interactive dashboards and business insight visualization.

  
- Tableau Dashboard

The interactive Tableau dashboard presents key business insights through visualizations covering sales performance, customer behavior, payment preferences, delivery performance, and customer satisfaction.
https://public.tableau.com/shared/NMKN2JB6F?:display_count=n&:origin=viz_share_link

## Key Findings

- **Customer Retention:** Only 3.12% of customers made repeat purchases.
- **Revenue Concentration:** São Paulo accounted for 37.5% of total payment revenue.
- **Payment Preferences:** Credit cards represented 78.3% of total payment value.
- **Delivery Performance:** Average delivery time was 12.56 days, with 8.11% of delivered orders arriving late.
- **Customer Reviews:** Office furniture had the lowest average review score among the product categories analyzed, at 3.52 out of 5.

## Business Recommendations

- Encourage repeat purchases through loyalty programs and second-purchase offers.
- Investigate delivery delays in states with high late-delivery rates.
- Examine product quality and customer feedback in low-rated categories.
- Reduce dependence on a small number of revenue-generating regions.
- Prepare inventory and delivery capacity for seasonal sales peaks.
- Maintain installment payment options to support customer purchasing preferences.

## Project Structure

| Folder | Description |
|---|---|
| `sql/` | SQL queries, database preparation, and business analysis |
| `python/` | Data cleaning, exploratory analysis, and visualizations |
| `tableau/` | Interactive dashboards and visual business insights |

## Project Status

This project is being developed in stages, with SQL analysis followed by Python analysis and Tableau dashboard development.

## Author

International Business student interested in data analytics, digital marketing, and data-driven business decisions.

### 3.2 Data Types

After importing the data, some columns had unsuitable data types and were converted as follows:

- **Dates:** Changed the five date columns in `orders` to `DATETIME` for calculations such as delivery duration and monthly trends. Empty values were converted to `NULL` first.
- **Money:** Changed `price`, `freight_value`, and `payment_value` to `DECIMAL(10,2)` to preserve monetary precision.
- **Text:** Changed short text columns, such as status, city, state, payment type, and category name, from `TEXT` to `VARCHAR`. State columns were changed to `CHAR(2)` because they contain two-letter codes. Column sizes were selected based on the longest values in the data.
- **Keys:** Changed ID columns to `VARCHAR(50)` or `VARCHAR(100)` to support their use as indexed key columns in MySQL.

### 3.3 Import Issues and Fixes

- **Missing Product Records**
  - The import wizard skipped 610 products with blank `product_photos_qty` values.
  - Restored these records using a SQL script, bringing the total to 32,951 products.

- **Incomplete Seller Import**
  - The initial import loaded only 309 of 3,095 sellers, possibly due to special characters in city names.
  - Reloaded the seller data using a SQL script.

- **Missing Category Translations**
  - Three categories used in the product data were missing from `category_translation`: `unknown`, `pc_gamer`, and one kitchen category.
  - Added the missing categories to support category mapping and joins.

### 3.4 Analysis Rules

- Delivery analysis includes only delivered orders with a recorded delivery date.
- Categories with fewer than 500 items are excluded from category rankings to reduce the influence of small categories.
- The `unknown` category, representing 610 products, is excluded from the review ranking because it does not represent a specific product category.
- - Delivery analysis uses delivered orders with a delivery date only (96,470 of 96,478 delivered orders).

## 4. Key Performance Indicators (KPIs)

The following KPIs provide an overview of the business.

| KPI | Value |
|---|---:|
| Product revenue (item price) | 13,591,643.70 |
| Freight | 2,251,909.54 |
| Total paid by customers | 16,008,872.12 |
| Total orders | 99,441 |
| Delivered orders | 96,478 |
| Unique customers | 96,096 |
| Revenue per customer (total paid) | 166.59 |
| Average review score | 4.09 / 5 |

**Note:** Product revenue and total paid are different metrics. Total paid includes freight and installment interest.

## 5. Business Analysis

### 5.1 Sales and Product Performance

#### Q1. How does revenue change by month?

**Key findings**

- Monthly product revenue increased from approximately 112,000 in January 2017 to approximately 950,000 in early 2018.
- November 2017 was the strongest month, with approximately 987,765 in revenue.
- Revenue increased by approximately 52% compared with October 2017.
- Growth flattened in 2018.

**Business insight**

The November revenue increase may be associated with seasonal shopping events such as Black Friday. Businesses should prepare inventory and delivery capacity for peak sales periods.

#### Q2. Which product categories generate the most revenue?

| Category | Revenue | Revenue Share |
|---|---:|---:|
| `health_beauty` | 1,258,681 | 9.3% |
| `watches_gifts` | 1,205,006 | 8.9% |
| `bed_bath_table` | 1,036,989 | 7.6% |
| `sports_leisure` | 988,049 | 7.3% |
| `computers_accessories` | 911,954 | 6.7% |

**Business insight**

The top five categories account for approximately 40% of product revenue. Although these categories are important contributors, no single category dominates the business.

### 5.2 Payment Analysis

#### Q3. Which payment type is used most?

| Payment Type | Share of Payment Value |
|---|---:|
| Credit card | 78.3% |
| Boleto | 17.9% |
| Voucher and debit card combined | Under 4% |

**Business insight**

Credit cards account for most payment value, with approximately 3.5 installments on average. Maintaining installment payment options is important for supporting customer purchasing preferences.

### 5.3 Customer and Regional Analysis

#### Q4. How many customers make repeat purchases?

| Metric | Value |
|---|---:|
| Unique customers | 96,096 |
| Repeat customers | 2,997 |
| Repeat-customer rate | 3.12% |

**Business insight**

Only 3.12% of customers placed more than one order. This suggests a potential customer-retention opportunity. Loyalty programs and second-purchase offers could encourage customers to return.

#### Q5. Which states generate the most revenue?

| State | Share of Total Payment Revenue |
|---|---:|
| São Paulo (SP) | 37.5% |
| Rio de Janeiro (RJ) | 13.4% |
| Minas Gerais (MG) | 11.7% |

**Business insight**

São Paulo, Rio de Janeiro, and Minas Gerais together account for 62.6% of total payment revenue. Revenue is concentrated in a small number of states, suggesting an opportunity to develop markets in other regions.

### 5.4 Delivery Analysis

#### Q6. How well are orders delivered overall?

| Metric | Result |
|---|---:|
| Average delivery time | 12.56 days |
| On-time delivery rate | 91.89% |
| Late-delivery rate | 8.11% |
| Late deliveries | 7,826 orders |

**Business insight**

Most delivered orders arrived on time, but approximately 8.11% were late. Improving delivery reliability could help improve the customer experience.

#### Q7. Which states have the highest late-delivery rates?

The analysis includes states with at least 1,000 delivered orders.

| State | Late-Delivery Rate |
|---|---:|
| Ceará (CE) | 15.3% |
| Bahia (BA) | 14.0% |
| Rio de Janeiro (RJ) | 13.5% |
| Espírito Santo (ES) | 12.2% |
| São Paulo (SP) | 5.9% |

**Business insight**

Late-delivery rates vary across states. Ceará, Bahia, Rio de Janeiro, and Espírito Santo have higher rates, while São Paulo performs better among the states listed. These regions may benefit from further investigation into logistics and delivery operations.

#### Q9. Which product categories have the lowest review scores?

This analysis includes delivered orders, excludes the `unknown` category, and considers categories with at least 500 items.

| Category | Items | Average Review Score | Late-Delivery Rate |
|---|---:|---:|---:|
| `office_furniture` | 1,664 | 3.52 | 8.8% |
| `bed_bath_table` | 10,985 | 3.92 | 8.2% |
| `furniture_decor` | 8,159 | 3.95 | 8.3% |
| `home_construction` | 593 | 3.96 | 8.3% |
| `computers_accessories` | 7,671 | 3.99 | 7.6% |

**Business insight**

Office furniture has the lowest average review score among the categories analyzed, at 3.52 out of 5. The late-delivery rates for these categories are relatively close to the overall late-delivery rate reported in the analysis.

This suggests that delivery delays alone may not explain the lower review scores. Product quality, assembly difficulties, and differences between product descriptions and customer expectations are potential areas for further investigation.

## 6. Key Findings and Business Recommendations

### 6.1 Improve Customer Retention

Only 3.12% of customers made repeat purchases.

**Recommendation:** Introduce loyalty programs, personalized promotions, and second-purchase offers to encourage repeat orders.

### 6.2 Improve Delivery Performance

Some states have considerably higher late-delivery rates than others.

**Recommendation:** Investigate logistics operations in Ceará, Bahia, Rio de Janeiro, and Espírito Santo to identify opportunities to improve delivery reliability.

### 6.3 Investigate Product Quality

Office furniture and several other categories have relatively low average review scores.

**Recommendation:** Examine product quality, assembly instructions, product descriptions, and customer feedback to identify the main causes of dissatisfaction.

### 6.4 Diversify Regional Revenue

São Paulo alone contributes 37.5% of total payment revenue, while the top three states account for 62.6%.

**Recommendation:** Explore opportunities to attract customers in other states and reduce dependence on the largest regional markets.

### 6.5 Prepare for Seasonal Demand

November 2017 recorded the highest monthly product revenue, increasing approximately 52% from October.

**Recommendation:** Prepare inventory, staffing, and delivery capacity ahead of major shopping periods.

### 6.6 Maintain Installment Payment Options

Credit cards account for 78.3% of total payment value.

**Recommendation:** Maintain convenient installment options while monitoring payment preferences and their contribution to sales.

## 7. Conclusion

The SQL analysis highlights several important business opportunities in the Olist e-commerce dataset. Customer retention is low, revenue is concentrated in a few states, delivery performance varies by region, and some product categories receive lower customer review scores.

These findings can help guide further investigation and business decisions. The project can be extended through Python for deeper exploratory data analysis and Tableau for interactive dashboards that communicate key metrics and trends.

