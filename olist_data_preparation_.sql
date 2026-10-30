-- =========================================
-- OLIST E-COMMERCE DATA PREPARATION
-- =========================================

-- Select the project database

USE olist_analysis;


-- Check the original table names

SHOW TABLES;

-- 01. RENAME TABLES

-- Rename the original Olist tables to shorter names

RENAME TABLE
    olist_orders_dataset TO orders,
    olist_customers_dataset TO customers,
    olist_order_items_dataset TO order_items,
    olist_order_payments_dataset TO payments,
    olist_products_dataset TO products,
    olist_products_cleaned TO products_cleaned,
    olist_sellers_dataset TO sellers,
    product_category_name_translation TO category_translation,
    olist_order_reviews_dataset TO reviews;


-- Check the table names after renaming

SHOW TABLES;



 -- 02. DATABASE SETUP

-- Check the number of rows in all project tables

SELECT COUNT(*) AS total_customers
FROM customers;

SELECT COUNT(*) AS total_orders
FROM orders;

SELECT COUNT(*) AS total_order_items
FROM order_items;

SELECT COUNT(*) AS total_products
FROM products_cleaned;

SELECT COUNT(*) AS total_sellers
FROM sellers;

SELECT COUNT(*) AS total_payments
FROM payments;

SELECT COUNT(*) AS total_reviews
FROM reviews;

SELECT COUNT(*) AS total_category_translations
FROM category_translation;

SELECT COUNT(*) AS total_geolocation
FROM geolocation;



-- 03. DATA CLEANING AND MISSING VALUE HANDLING


-- Disable safe update mode for data cleaning

SET SQL_SAFE_UPDATES = 0;


-- Replace blank date values with NULL

UPDATE orders
SET
    order_approved_at = NULLIF(TRIM(order_approved_at), ''),
    order_delivered_carrier_date = NULLIF(TRIM(order_delivered_carrier_date), ''),
    order_delivered_customer_date = NULLIF(TRIM(order_delivered_customer_date), ''),
    order_purchase_timestamp = NULLIF(TRIM(order_purchase_timestamp), ''),
    order_estimated_delivery_date = NULLIF(TRIM(order_estimated_delivery_date), '');


-- Check for remaining blank date values

SELECT
    SUM(order_approved_at = '') AS blank_approved_dates,
    SUM(order_delivered_carrier_date = '') AS blank_carrier_dates,
    SUM(order_delivered_customer_date = '') AS blank_customer_dates,
    SUM(order_purchase_timestamp = '') AS blank_purchase_dates,
    SUM(order_estimated_delivery_date = '') AS blank_estimated_dates
FROM orders;


-- Check for missing product categories

SELECT COUNT(*) AS missing_category_count
FROM products_cleaned
WHERE product_category_name IS NULL
   OR TRIM(product_category_name) = '';


-- Replace NULL and blank product categories with 'unknown'

UPDATE products_cleaned
SET product_category_name = 'unknown'
WHERE product_category_name IS NULL
   OR TRIM(product_category_name) = '';


-- Check the number of products with unknown categories

SELECT COUNT(*) AS unknown_category_count
FROM products_cleaned
WHERE product_category_name = 'unknown';


-- Check missing product photo quantities

SELECT COUNT(*) AS missing_photo_quantity
FROM products_cleaned
WHERE product_photos_qty IS NULL;



-- 04. DATA TYPE CONVERSION


-- Convert order date columns to DATETIME

ALTER TABLE orders
    MODIFY order_purchase_timestamp DATETIME,
    MODIFY order_approved_at DATETIME,
    MODIFY order_delivered_carrier_date DATETIME,
    MODIFY order_delivered_customer_date DATETIME,
    MODIFY order_estimated_delivery_date DATETIME;


-- Modify order status

ALTER TABLE orders
    MODIFY order_status VARCHAR(20);


-- Modify customer columns

ALTER TABLE customers
    MODIFY customer_unique_id VARCHAR(50),
    MODIFY customer_city VARCHAR(100),
    MODIFY customer_state CHAR(2);


-- Modify seller columns

ALTER TABLE sellers
    MODIFY seller_city VARCHAR(100),
    MODIFY seller_state CHAR(2);


-- Modify payment columns

ALTER TABLE payments
    MODIFY payment_type VARCHAR(20),
    MODIFY payment_value DECIMAL(10,2);


-- Modify order item columns

ALTER TABLE order_items
    MODIFY price DECIMAL(10,2),
    MODIFY freight_value DECIMAL(10,2);


-- Modify product category column

ALTER TABLE products_cleaned
    MODIFY product_category_name VARCHAR(100);


-- Modify category translation columns

ALTER TABLE category_translation
    MODIFY product_category_name VARCHAR(100),
    MODIFY product_category_name_english VARCHAR(100);



-- 05. PRIMARY KEY CONSTRAINTS


-- Customers

ALTER TABLE customers
    ADD PRIMARY KEY (customer_id);


-- Orders

ALTER TABLE orders
    ADD PRIMARY KEY (order_id);


-- Products

ALTER TABLE products_cleaned
    ADD PRIMARY KEY (product_id);


-- Order Items

ALTER TABLE order_items
    ADD PRIMARY KEY (order_id, order_item_id);


-- Sellers

ALTER TABLE sellers
    ADD PRIMARY KEY (seller_id);


-- Payments

ALTER TABLE payments
    ADD PRIMARY KEY (order_id, payment_sequential);


-- Reviews

ALTER TABLE reviews
    ADD PRIMARY KEY (review_id, order_id);


-- Category Translation

ALTER TABLE category_translation
    ADD PRIMARY KEY (product_category_name);





-- 06. FOREIGN KEY CONSTRAINTS


-- Orders -> Customers

ALTER TABLE orders
    ADD CONSTRAINT fk_orders_customers
    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id);


-- Order Items -> Orders

ALTER TABLE order_items
    ADD CONSTRAINT fk_order_items_orders
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id);


-- Ensure compatible data types for the product relationship

ALTER TABLE order_items
    MODIFY product_id VARCHAR(50);


-- Order Items -> Products

ALTER TABLE order_items
    ADD CONSTRAINT fk_order_items_products
    FOREIGN KEY (product_id)
    REFERENCES products_cleaned(product_id);


-- Ensure compatible data type for the seller relationship

ALTER TABLE order_items
    MODIFY seller_id VARCHAR(50) NOT NULL;


-- Order Items -> Sellers

ALTER TABLE order_items
    ADD CONSTRAINT fk_order_items_sellers
    FOREIGN KEY (seller_id)
    REFERENCES sellers(seller_id);


-- Payments -> Orders

ALTER TABLE payments
    ADD CONSTRAINT fk_payments_orders
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id);


-- Reviews -> Orders

ALTER TABLE reviews
    ADD CONSTRAINT fk_reviews_orders
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id);


-- Products -> Category Translation

ALTER TABLE products_cleaned
    ADD CONSTRAINT fk_products_category
    FOREIGN KEY (product_category_name)
    REFERENCES category_translation(product_category_name);


-- 07. DATA VALIDATION


-- Recheck row counts for all project tables after data preparation

SELECT COUNT(*) AS total_customers
FROM customers;

SELECT COUNT(*) AS total_orders
FROM orders;

SELECT COUNT(*) AS total_order_items
FROM order_items;

SELECT COUNT(*) AS total_products
FROM products_cleaned;

SELECT COUNT(*) AS total_sellers
FROM sellers;

SELECT COUNT(*) AS total_payments
FROM payments;

SELECT COUNT(*) AS total_reviews
FROM reviews;

SELECT COUNT(*) AS total_category_translations
FROM category_translation;

SELECT COUNT(*) AS total_geolocation
FROM geolocation;


-- Check products with unknown categories

SELECT COUNT(*) AS unknown_category_count
FROM products_cleaned
WHERE product_category_name = 'unknown';


-- Check whether any product categories are still NULL

SELECT COUNT(*) AS null_category_count
FROM products_cleaned
WHERE product_category_name IS NULL;


-- Check product category distribution

SELECT
    product_category_name,
    COUNT(*) AS total_products
FROM products_cleaned
GROUP BY product_category_name
ORDER BY total_products DESC;



-- 08. CREATE SQL VIEWS FOR TABLEAU ANALYSIS


-- One row per ITEM
-- Used for revenue, product categories, and seller analysis

CREATE OR REPLACE VIEW v_order_items AS
SELECT
    oi.order_id,
    oi.order_item_id,
    o.order_status,
    o.order_purchase_timestamp,
    oi.price,
    oi.freight_value,
    oi.seller_id,
    s.seller_state,
    cu.customer_unique_id,
    cu.customer_state,
    COALESCE(t.product_category_name_english, 'unknown') AS category
FROM order_items oi
JOIN orders o
    ON o.order_id = oi.order_id
JOIN customers cu
    ON cu.customer_id = o.customer_id
LEFT JOIN products_cleaned p
    ON p.product_id = oi.product_id
LEFT JOIN category_translation t
    ON t.product_category_name = p.product_category_name
LEFT JOIN sellers s
    ON s.seller_id = oi.seller_id;


-- One row per ORDER
-- Used for order, delivery, review, and customer analysis

CREATE OR REPLACE VIEW v_orders AS
SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    cu.customer_unique_id,
    cu.customer_state,
    pay.total_paid,
    rev.review_score,

    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
        THEN TIMESTAMPDIFF(
            SECOND,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) / 86400
    END AS delivery_days,

    CASE
        WHEN o.order_delivered_customer_date IS NULL THEN NULL
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
        ELSE 0
    END AS is_late,

    COUNT(*) OVER (
        PARTITION BY cu.customer_unique_id
    ) AS customer_total_orders

FROM orders o
JOIN customers cu
    ON cu.customer_id = o.customer_id
LEFT JOIN (
    SELECT
        order_id,
        SUM(payment_value) AS total_paid
    FROM payments
    GROUP BY order_id
) pay
    ON pay.order_id = o.order_id
LEFT JOIN (
    SELECT
        order_id,
        AVG(review_score) AS review_score
    FROM reviews
    GROUP BY order_id
) rev
    ON rev.order_id = o.order_id;


-- One row per PAYMENT
-- Used for payment type and installment analysis

CREATE OR REPLACE VIEW v_payments AS
SELECT
    p.order_id,
    p.payment_sequential,
    p.payment_type,
    p.payment_installments,
    p.payment_value,
    o.order_purchase_timestamp,
    cu.customer_state
FROM payments p
JOIN orders o
    ON o.order_id = p.order_id
JOIN customers cu
    ON cu.customer_id = o.customer_id;



-- END OF DATA PREPARATION

