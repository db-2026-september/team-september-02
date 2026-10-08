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
-- Максим: меню, категорії та базові в'юшки
-- ================================================================

DROP VIEW IF EXISTS deserts_category_view;
DROP VIEW IF EXISTS join_tables_view;
DROP VIEW IF EXISTS menu_mixed_view;
DROP VIEW IF EXISTS menu_vertical_view;
DROP VIEW IF EXISTS menu_horizontal_view;

-- 1. Швидкі страви (готуються до 20 хв)
CREATE OR REPLACE VIEW menu_horizontal_view AS
SELECT *
FROM menu_items
WHERE preparation_time_min <= 20;

-- 2. Тільки назви та категорії (без описів)
CREATE OR REPLACE VIEW menu_vertical_view AS
SELECT category_id, name
FROM menu_categories;

-- 3. Доступні страви дорожчі за 300 грн
CREATE OR REPLACE VIEW menu_mixed_view AS
SELECT name, price, is_available
FROM menu_items
WHERE price > 300 AND is_available = TRUE;

-- 4. Зв'язуємо страви з їхніми категоріями через JOIN
CREATE OR REPLACE VIEW join_tables_view AS
SELECT menu_items.name AS dish_name, menu_categories.name AS category_name
FROM menu_items
JOIN menu_categories
  ON menu_items.category_id = menu_categories.category_id;

-- 8. Десерти до 265 грн з захистом (CHECK OPTION)
CREATE OR REPLACE VIEW deserts_category_view AS
SELECT *
FROM menu_items
WHERE category_id = 5 AND price < 265
WITH CHECK OPTION;


-- ================================================================
-- Віталій: склади, контакти та замовлення
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

-- Коротка інфо по клієнтах
CREATE VIEW customer_short_info_view AS
SELECT 
    customer_id,
    first_name,
    last_name
FROM customers;

-- Де закінчуються запаси на складах
CREATE VIEW low_stock_inventory_view AS
SELECT 
    location_id,
    ingredient_id,
    current_stock,
    min_stock_level
FROM location_inventory
WHERE current_stock <= min_stock_level;

-- Тільки позитивні відгуки (рейтинг 4 і вище)
CREATE VIEW positive_feedback_view AS
SELECT 
    order_id,
    location_id,
    rating,
    comment,
    created_at
FROM customer_feedback
WHERE rating >= 4;

-- Деталізовані замовлення з усіма зв'язками (JOIN)
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

-- Категоризація замовлень за сумою (через підзапит з середнім)
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

-- Зведений список контактів (робітники, постачальники, клієнти через UNION)
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

-- Багаторівневі в'юхи по складах (перший шар і агрегація)
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

CREATE VIEW location_inventory_summary_view AS
SELECT 
    location_id,
    location_name,
    COUNT(*) AS total_ingredients_tracked,
    SUM(is_below_minimum) AS items_needing_restock
FROM location_inventory_detailed_view
GROUP BY location_id, location_name;

-- Тільки активні локації з CHECK OPTION
CREATE VIEW active_locations_view AS
SELECT 
    location_id,
    name,
    address,
    is_active
FROM locations
WHERE is_active = true
WITH CHECK OPTION;


-- ================================================================
-- Олексій: замовлення, міста та резерви
-- ================================================================

DROP VIEW IF EXISTS city_totals_view;
DROP VIEW IF EXISTS lviv_orders_view;
DROP VIEW IF EXISTS orders_details_view;
DROP VIEW IF EXISTS reservations_view;
DROP VIEW IF EXISTS customers_view;
DROP VIEW IF EXISTS orders_view;

-- Тільки базові поля замовлень
create view orders_view as
select 
  order_number
  ,order_type
  ,ordered_at
  ,total_order_amount
from public.orders;

-- Клієнти без анонімів
create view customers_view as
select 
  first_name
  ,last_name
  ,phone
from public.customers
where first_name != 'Анонім';

-- Великі бронювання (від 5 гостей)
create view reservations_view as
select 
  reservation_datetime
  ,guests_count
from public.reservations
where guests_count >= 5;

-- Зв'язок замовлень з локаціями та позиціями
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

-- Замовлення по Львову (через підзапит)
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
                      where name like '%Lviv%');

-- Підсумки по містах (на основі іншої в'юшки)
create view city_totals_view as
select
  split_part(name, ' ', 1) as city
  ,sum(quantity) as total_quantity
  ,sum(total_order_amount) as total_amount
from orders_details_view
group by city
order by total_amount desc;


-- ================================================================
-- Валерій: персонал, зміни та графіки
-- ================================================================

DROP VIEW IF EXISTS scheduled_shifts_view;
DROP VIEW IF EXISTS location_shift_summary_view;
DROP VIEW IF EXISTS shift_timeline_view;
DROP VIEW IF EXISTS staff_above_avg_hours_view;
DROP VIEW IF EXISTS shift_details_view;
DROP VIEW IF EXISTS active_staff_contacts_view;
DROP VIEW IF EXISTS open_shifts_view;
DROP VIEW IF EXISTS staff_directory_view;

-- Довідник персоналу (без особистих даних)
CREATE VIEW staff_directory_view AS
SELECT
    staff_id,
    location_id,
    last_name,
    first_name,
    position
FROM staff;

-- Тільки відкриті/актуальні зміни
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

-- Контакти працюючого персоналу
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

-- Повна інфо по змінах (з JOIN та підрахунком годин/запізнень)
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

-- Хто відпрацював більше середнього (складний підзапит)
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

-- Таймлайн змін (об'єднання актуальних та історії через UNION)
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

-- Зведення по локаціях (багаторівнева в'юха)
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

-- Тільки заплановані зміни з CHECK OPTION
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


-- ================================================================
-- Демо та перевірки
-- ================================================================

-- Перевірка роботи в'юшок
SELECT * FROM menu_horizontal_view;
SELECT * FROM customer_short_info_view LIMIT 5;
SELECT * FROM orders_view LIMIT 5;
SELECT * FROM staff_directory_view ORDER BY location_id, last_name;

-- Тести для перевірки CHECK OPTION (Валерій)
BEGIN;
UPDATE scheduled_shifts_view
SET start_time = start_time + INTERVAL '30 minutes',
    end_time   = end_time   + INTERVAL '30 minutes'
WHERE staff_id = (SELECT staff_id FROM staff WHERE email = 'olena.koval@staff.example.ua')
  AND start_time = '2026-10-06 07:30+03';
ROLLBACK;

-- Перевірка блокування зміни статусу через в'юшку
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
