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




-- ================================================================
-- Topic: Database Views lesson 10
-- Author: Valerii Kyrpychenko
-- ================================================================

DROP VIEW IF EXISTS scheduled_shifts_view;
DROP VIEW IF EXISTS location_shift_summary_view;
DROP VIEW IF EXISTS shift_timeline_view;
DROP VIEW IF EXISTS staff_above_avg_hours_view;
DROP VIEW IF EXISTS shift_details_view;
DROP VIEW IF EXISTS active_staff_contacts_view;
DROP VIEW IF EXISTS open_shifts_view;
DROP VIEW IF EXISTS staff_directory_view;


-- ----------------------------------------------------------------
-- 1. Горизонтальне представлення
-- Довідник персоналу без персональних даних (дата народження, контакти).
-- ----------------------------------------------------------------
CREATE VIEW staff_directory_view AS
SELECT
    staff_id,
    location_id,
    last_name,
    first_name,
    position
FROM staff;


-- ----------------------------------------------------------------
-- 2. Вертикальне представлення
-- Лише незавершені зміни (заплановані та поточні).
-- ----------------------------------------------------------------
CREATE VIEW open_shifts_view AS
SELECT
    shift_id,
    location_id,
    staff_id,
    start_time,
    end_time,
    actual_start_time,
    actual_end_time,
    break_time_minutes,
    status
FROM shift_schedules
WHERE status IN ('SCHEDULED', 'IN_PROGRESS');


-- ----------------------------------------------------------------
-- 3. Змішане представлення
-- Контакти лише чинних працівників (звільнені мають is_active = false).
-- ----------------------------------------------------------------
CREATE VIEW active_staff_contacts_view AS
SELECT
    staff_id,
    location_id,
    last_name || ' ' || first_name AS employee,
    position,
    phone,
    email
FROM staff
WHERE is_active = true;


-- ----------------------------------------------------------------
-- 4. Представлення з JOIN
-- Зміна + працівник + локація, плановані/відпрацьовані години та запізнення.
-- ----------------------------------------------------------------
CREATE VIEW shift_details_view AS
SELECT
    sh.shift_id,
    sh.location_id,
    l.name                                  AS location_name,
    sh.staff_id,
    st.last_name || ' ' || st.first_name    AS employee,
    st.position,
    sh.start_time,
    sh.end_time,
    sh.actual_start_time,
    sh.actual_end_time,
    sh.break_time_minutes,
    sh.status,
    ROUND((EXTRACT(EPOCH FROM (sh.end_time - sh.start_time)) / 3600)::numeric, 2)
                                            AS planned_hours,
    ROUND((EXTRACT(EPOCH FROM (sh.actual_end_time - sh.actual_start_time)) / 3600
           - sh.break_time_minutes / 60.0)::numeric, 2)
                                            AS worked_hours,
    CASE
        WHEN sh.actual_start_time IS NULL THEN NULL
        WHEN sh.actual_start_time > sh.start_time
            THEN ROUND((EXTRACT(EPOCH FROM (sh.actual_start_time - sh.start_time)) / 60)::numeric)
        ELSE 0
    END                                     AS late_minutes
FROM shift_schedules sh
JOIN staff     st ON st.staff_id   = sh.staff_id
JOIN locations l  ON l.location_id = sh.location_id;


-- ----------------------------------------------------------------
-- 5. Представлення з підзапитом
-- Працівники, які відпрацювали більше середнього (лише COMPLETED зміни).
-- ----------------------------------------------------------------
CREATE VIEW staff_above_avg_hours_view AS
SELECT
    st.staff_id,
    st.last_name || ' ' || st.first_name AS employee,
    st.position,
    st.location_id,
    w.completed_shifts,
    w.worked_hours
FROM staff st
JOIN (
    SELECT
        staff_id,
        COUNT(*) AS completed_shifts,
        ROUND(SUM(EXTRACT(EPOCH FROM (actual_end_time - actual_start_time)) / 3600
                  - break_time_minutes / 60.0)::numeric, 2) AS worked_hours
    FROM shift_schedules
    WHERE status = 'COMPLETED'
      AND actual_end_time IS NOT NULL
    GROUP BY staff_id
) w ON w.staff_id = st.staff_id
WHERE w.worked_hours > (
    SELECT AVG(t.hours)
    FROM (
        SELECT SUM(EXTRACT(EPOCH FROM (actual_end_time - actual_start_time)) / 3600
                   - break_time_minutes / 60.0) AS hours
        FROM shift_schedules
        WHERE status = 'COMPLETED'
          AND actual_end_time IS NOT NULL
        GROUP BY staff_id
    ) t
);


-- ----------------------------------------------------------------
-- 6. Представлення з UNION
-- Актуальні зміни (ACTUAL) та історія змін (HISTORY) в одному списку.
-- ----------------------------------------------------------------
CREATE VIEW shift_timeline_view AS
SELECT
    'ACTUAL'::text AS shift_group,
    sh.shift_id,
    sh.location_id,
    st.last_name || ' ' || st.first_name AS employee,
    sh.start_time,
    sh.end_time,
    sh.status
FROM shift_schedules sh
JOIN staff st ON st.staff_id = sh.staff_id
WHERE sh.status IN ('SCHEDULED', 'IN_PROGRESS')

UNION ALL

SELECT
    'HISTORY'::text AS shift_group,
    sh.shift_id,
    sh.location_id,
    st.last_name || ' ' || st.first_name AS employee,
    sh.start_time,
    sh.end_time,
    sh.status
FROM shift_schedules sh
JOIN staff st ON st.staff_id = sh.staff_id
WHERE sh.status IN ('COMPLETED', 'NO_SHOW', 'CANCELLED');


-- ----------------------------------------------------------------
-- 7. Багаторівневе представлення (на основі shift_details_view)
-- Зведення по локаціях: зміни, неявки, запізнення, години.
-- ----------------------------------------------------------------
CREATE VIEW location_shift_summary_view AS
SELECT
    location_id,
    location_name,
    COUNT(*)                                       AS total_shifts,
    COUNT(*) FILTER (WHERE status = 'COMPLETED')   AS completed_shifts,
    COUNT(*) FILTER (WHERE status = 'NO_SHOW')     AS no_show_shifts,
    COUNT(*) FILTER (WHERE late_minutes > 0)       AS late_arrivals,
    COALESCE(SUM(worked_hours), 0)                 AS total_worked_hours
FROM shift_details_view
GROUP BY location_id, location_name;


-- ----------------------------------------------------------------
-- 8. Представлення з WITH CHECK OPTION
-- Редагування лише запланованих змін; змінити статус через нього не можна.
-- ----------------------------------------------------------------
CREATE VIEW scheduled_shifts_view AS
SELECT
    shift_id,
    location_id,
    staff_id,
    start_time,
    end_time,
    break_time_minutes,
    status
FROM shift_schedules
WHERE status = 'SCHEDULED'
WITH CHECK OPTION;


-- ----------------------------------------------------------------
-- Sample checks
-- ----------------------------------------------------------------
SELECT * FROM staff_directory_view        ORDER BY location_id, last_name;
SELECT * FROM open_shifts_view            ORDER BY start_time;
SELECT * FROM active_staff_contacts_view  ORDER BY location_id;
SELECT * FROM shift_details_view          ORDER BY start_time;
SELECT * FROM staff_above_avg_hours_view  ORDER BY worked_hours DESC;
SELECT * FROM shift_timeline_view         ORDER BY shift_group, start_time;
SELECT * FROM location_shift_summary_view ORDER BY location_id;
SELECT * FROM scheduled_shifts_view       ORDER BY start_time;


-- ----------------------------------------------------------------
-- CHECK OPTION tests
-- ----------------------------------------------------------------

-- Дозволено: перенесення запланованої зміни (з ROLLBACK)
BEGIN;
UPDATE scheduled_shifts_view
SET start_time = start_time + INTERVAL '30 minutes',
    end_time   = end_time   + INTERVAL '30 minutes'
WHERE staff_id = (SELECT staff_id FROM staff WHERE email = 'olena.koval@staff.example.ua')
  AND start_time = '2026-10-06 07:30+03';
ROLLBACK;

-- Заборонено: зміна статусу на COMPLETED
DO $$
BEGIN
  UPDATE scheduled_shifts_view
  SET status = 'COMPLETED'
  WHERE staff_id = (SELECT staff_id FROM staff WHERE email = 'olena.koval@staff.example.ua')
    AND start_time = '2026-10-06 07:30+03';
  RAISE EXCEPTION 'not triggered';
EXCEPTION
  WHEN with_check_option_violation THEN RAISE NOTICE '[OK] CHECK OPTION (UPDATE): %', SQLERRM;
  WHEN raise_exception             THEN RAISE NOTICE '[FAIL] CHECK OPTION (UPDATE)';
END $$;

-- Заборонено: вставка зміни зі статусом CANCELLED
DO $$
BEGIN
  INSERT INTO scheduled_shifts_view (location_id, staff_id, start_time, end_time, status)
  SELECT location_id, staff_id, '2026-10-25 09:00+03', '2026-10-25 18:00+03', 'CANCELLED'
  FROM staff WHERE email = 'olena.koval@staff.example.ua';
  RAISE EXCEPTION 'not triggered';
EXCEPTION
  WHEN with_check_option_violation THEN RAISE NOTICE '[OK] CHECK OPTION (INSERT): %', SQLERRM;
  WHEN raise_exception             THEN RAISE NOTICE '[FAIL] CHECK OPTION (INSERT)';
END $$;





-- ================================================================
-- Topic: Database Views lesson 10
-- Author: Oleksii Antypov
-- ================================================================

-- DROP VIEW IF EXISTS orders_view;
-- DROP VIEW IF EXISTS customers_view;
-- DROP VIEW IF EXISTS reservations_view;
-- DROP VIEW IF EXISTS city_totals_view;
-- DROP VIEW IF EXISTS orders_details_view;
-- DROP VIEW IF EXISTS lviv_orders_view;

------------------------------------------------------------------
-- 1. Horizontal view
------------------------------------------------------------------
create view orders_view as
select 
  order_number
  ,order_type
  ,ordered_at
  ,total_order_amount
from public.orders;

------------------------------------------------------------------
-- 2. Vertical view
------------------------------------------------------------------
create view customers_view as
select 
  first_name
  ,last_name
  ,phone
from public.customers
where first_name != 'Анонім';

------------------------------------------------------------------
-- 3. Mixed view
------------------------------------------------------------------
create view reservations_view as
select 
  reservation_datetime
  ,guests_count
from public.reservations
where guests_count >= 5;

------------------------------------------------------------------
-- 4. View that joins multiple tables
------------------------------------------------------------------
create view orders_details_view as
SELECT 
  l.name
  ,o.order_type
  ,o.status
  ,oi.quantity
  ,oi.item_price
  ,o.total_order_amount
FROM orders o
left join order_items oi on o.order_id = oi.order_id
left join locations l on l.location_id = o.location_id;

------------------------------------------------------------------
-- 5. View using a subquery
------------------------------------------------------------------
create view lviv_orders_view as
SELECT 
  'Lviv' as city
  ,order_number
  ,order_type
  ,ordered_at
  ,total_order_amount
FROM orders
where location_id in (select location_id 
                      from locations
                      where name like '%Lviv%')
;

------------------------------------------------------------------
-- 6. Layered view (View selecting from another view)
------------------------------------------------------------------
create view city_totals_view as
select
  split_part(name, ' ', 1) as city
  ,sum(quantity) as total_quantity
  ,sum(total_order_amount) as total_amount
from orders_details_view
group by city
order by total_amount desc;
