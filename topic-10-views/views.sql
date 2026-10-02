-- ================================================================
-- SQL VIEWS TEMPLATE (TOPIC 10)
-- ================================================================
-- WHAT SHOULD BE ADDED HERE:
-- 1) CREATE VIEW scripts for required view types:
--    - Horizontal view (select specific columns)
--    - Vertical view (filter specific rows)
--    - Mixed view (columns + row filters)
--    - Join-based view (multiple tables)
--    - Subquery-based view
--    - UNION-based view
--    - View based on another view
--    - Updatable view with WITH CHECK OPTION
--
-- 2) Comments before each view explaining:
--    - Purpose of the view
--    - How it supports your project design
--
-- 3) Optional demo SELECT statements to show view output.
--
-- RECOMMENDED ORDER:
-- 1) Simple views (horizontal / vertical / mixed)
-- 2) Join and subquery views
-- 3) UNION and layered views
-- 4) CHECK OPTION view
--
-- IMPORTANT:
-- - Script must execute in PostgreSQL without errors.
-- - Keep naming consistent and readable.
-- - Submit all views in this single SQL file.
-- ================================================================

-- Add your CREATE VIEW statements below this line

-- ================================================================
-- Topic: Database Views lesson 10
-- Author: Fronts Vitaliy
-- ================================================================

DROP VIEW IF EXISTS location_inventory_summary_view;
DROP VIEW IF EXISTS location_inventory_detailed_view;
DROP VIEW IF EXISTS active_locations_view;
DROP VIEW IF EXISTS company_contacts_view;
DROP VIEW IF EXISTS order_price_category_view;
DROP VIEW IF EXISTS detailed_orders_view;
DROP VIEW IF EXISTS positive_feedback_view;
DROP VIEW IF EXISTS low_stock_inventory_view;
DROP VIEW IF EXISTS customer_short_info_view;


-- ----------------------------------------------------------------
-- 1. Horizontal view
-- ----------------------------------------------------------------
CREATE VIEW customer_short_info_view AS
SELECT 
    customer_id,
    first_name,
    last_name
FROM customers;


-- ----------------------------------------------------------------
-- 2. Vertical view
-- ----------------------------------------------------------------
CREATE VIEW low_stock_inventory_view AS
SELECT 
    location_id,
    ingredient_id,
    current_stock,
    min_stock_level
FROM location_inventory
WHERE current_stock <= min_stock_level;


-- ----------------------------------------------------------------
-- 3. Mixed view
-- ----------------------------------------------------------------
CREATE VIEW positive_feedback_view AS
SELECT 
    order_id,
    location_id,
    rating,
    comment,
    created_at
FROM customer_feedback
WHERE rating >= 4;


-- ----------------------------------------------------------------
-- 4. View that joins multiple tables
-- ----------------------------------------------------------------
CREATE VIEW detailed_orders_view AS
SELECT 
    o.order_id,
    o.order_number,
    l.name AS location_name,
    c.first_name || ' ' || COALESCE(c.last_name, '') AS customer_name,
    c.phone AS customer_phone,
    o.order_type,
    o.status AS order_status,
    m.name AS item_name,
    oi.quantity,
    oi.item_price,
    (oi.quantity * oi.item_price) AS line_price,
    o.total_order_amount
FROM orders o
JOIN locations l ON o.location_id = l.location_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN menu_items m ON oi.menu_item_id = m.menu_item_id;


-- ----------------------------------------------------------------
-- 5. View using a subquery
-- ----------------------------------------------------------------
CREATE VIEW order_price_category_view AS
SELECT 
    order_id,
    order_number,
    location_id,
    total_order_amount,
    CASE 
        WHEN total_order_amount > (SELECT AVG(total_order_amount) FROM orders) 
            THEN 'Above Average'
        ELSE 'Below or Average'
    END AS spending_category
FROM orders;


-- ----------------------------------------------------------------
-- 6. View using UNION
-- ----------------------------------------------------------------
CREATE VIEW company_contacts_view AS
SELECT 
    'Staff' AS person_type,
    first_name || ' ' || last_name AS full_name,
    phone,
    email
FROM staff

UNION ALL

SELECT 
    'Supplier' AS person_type,
    name AS full_name,
    phone,
    email
FROM suppliers

UNION ALL

SELECT 
    'Customer' AS person_type,
    first_name || ' ' || COALESCE(last_name, '') AS full_name,
    phone,
    email
FROM customers
WHERE phone IS NOT NULL OR email IS NOT NULL;


-- ----------------------------------------------------------------
-- 7. Layered view (View selecting from another view)
-- ----------------------------------------------------------------

-- First layer view
CREATE VIEW location_inventory_detailed_view AS
SELECT 
    li.location_id,
    l.name AS location_name,
    i.name AS ingredient_name,
    li.current_stock,
    li.min_stock_level,
    CASE 
        WHEN li.current_stock <= li.min_stock_level THEN 1 
        ELSE 0 
    END AS is_below_minimum
FROM location_inventory li
JOIN locations l ON li.location_id = l.location_id
JOIN ingredients i ON li.ingredient_id = i.ingredient_id;

-- Second layer view (queries the 'location_inventory_detailed_view')
CREATE VIEW location_inventory_summary_view AS
SELECT 
    location_id,
    location_name,
    COUNT(*) AS total_ingredients_tracked,
    SUM(is_below_minimum) AS items_needing_restock
FROM location_inventory_detailed_view
GROUP BY location_id, location_name;


-- ----------------------------------------------------------------
-- 8. View with CHECK OPTION
-- ----------------------------------------------------------------
CREATE VIEW active_locations_view AS
SELECT 
    location_id,
    name,
    address,
    is_active
FROM locations
WHERE is_active = true
WITH CHECK OPTION;


-- ----------------------------------------------------------------
-- Sample checks
-- ----------------------------------------------------------------
SELECT * FROM customer_short_info_view LIMIT 5;
SELECT * FROM low_stock_inventory_view;
SELECT * FROM positive_feedback_view LIMIT 5;
SELECT * FROM detailed_orders_view LIMIT 5;
SELECT * FROM order_price_category_view LIMIT 5;
SELECT * FROM company_contacts_view LIMIT 10;
SELECT * FROM location_inventory_summary_view;
SELECT * FROM active_locations_view;

