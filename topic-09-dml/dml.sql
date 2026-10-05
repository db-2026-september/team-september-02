-- ================================================================
-- SQL DML TEMPLATE (TOPIC 09)
-- ================================================================
-- WHAT SHOULD BE ADDED HERE:
-- 1) INSERT scripts for all required tables in your database.
-- 2) At least 10 records per table with meaningful, realistic values.
-- 3) UPDATE / DELETE scripts where they are relevant to business logic.
-- 4) If UPDATE / DELETE are not relevant for a table, add a short note
--    in documentation explaining why.
-- 5) Comments by section so the script is easy to read and run.
--
-- SCRIPT GOALS:
-- - Populate the database with usable test data.
-- - Validate constraints through realistic DML scenarios.
-- - Support the core functionality of your application.
--
-- RECOMMENDED ORDER:
-- 1) Reference data (lookups/dictionaries)
-- 2) Core entities
-- 3) Transactional data
-- 4) Optional UPDATE / DELETE checks
--
-- IMPORTANT:
-- - Use anonymized or privacy-safe sample data where possible.
-- - The script must execute in PostgreSQL.
-- - Submit this as one SQL file.
-- ================================================================

-- Add your DML below this line


-- ================================================================
-- SQL DML (TOPIC 09)
-- AUTHOR: Vitaliy Fronts
-- ================================================================
-- ----------------------------------------------------------------
-- 0. ПІДГОТОВКА: ТЕСТОВІ ІНГРЕДІЄНТИ (REFERENCE DATA)
-- Оскільки location_inventory та supplier_ingredients залежать від таблиці ingredients,
-- додаємо базовий набір продуктів.
-- ----------------------------------------------------------------
INSERT INTO ingredients (ingredient_id, name, unit)
VALUES
  (1,  'Арабіка 100% (зерно)', 'кг'),
  (2,  'Молоко пастеризоване 3.2%', 'л'),
  (3,  'Вівсяне молоко Barista', 'л'),
  (4,  'Борошно пшеничне в/ґ', 'кг'),
  (5,  'Цукор білий', 'кг'),
  (6,  'Масло вершкове 82.5%', 'кг'),
  (7,  'Куряче філе охолоджене', 'кг'),
  (8,  'Сир Моцарела', 'кг'),
  (9,  'Томати свіжі', 'кг'),
  (10, 'Лосось слабосолений', 'кг'),
  (11, 'Оливкова олія Extra Virgin', 'л'),
  (12, 'Сироп ванільний', 'л');


-- ----------------------------------------------------------------
-- 1. INSERT: LOCATIONS (from google)
-- Поле location_id генерується автоматично
-- ----------------------------------------------------------------
INSERT INTO locations (location_id, name, address, is_active)
VALUES
  (1, 'Lviv Central Coffee Lab',       'м. Львів, пл. Ринок, 14',             true),
  (2, 'Lviv Sykhiv Bistro & Bakery',    'м. Львів, просп. Червоної Калини, 60',  true),
  (3, 'Kyiv Khreshchatyk Flagship',    'м. Київ, вул. Хрещатик, 22',           true),
  (4, 'Kyiv Podil Gastro Corner',      'м. Київ, вул. Петра Сагайдачного, 11',  true),
  (5, 'Kyiv Obolon Family Hub',        'м. Київ, Оболонський просп., 1Б',       true),
  (6, 'Odesa Derybasivska Lounge',     'м. Одеса, вул. Дерибасівська, 16',      true),
  (7, 'Dnipro Yavornytskoho Bistro',   'м. Дніпро, просп. Д. Яворницького, 48',  true),
  (8, 'Ivano-Frankivsk Urban Cafe',    'м. Івано-Франківськ, вул. Сотника Мартинця, 4', true),
  (9, 'Ternopil Lake Terrace',         'м. Тернопіль, вул. Руська, 17',         true),
  (10, 'Uzhhorod Castle View Point',    'м. Ужгород, вул. Корзо, 9',            true),
  (11, 'Lviv Arena Express (Seasonal)', 'м. Львів, вул. Стрийська, 199',        false);


-- ----------------------------------------------------------------
-- 2. INSERT: SUPPLIERS (as well from google)
-- Поле supplier_id генерується автоматично
-- ----------------------------------------------------------------
INSERT INTO suppliers (name, phone, email, address)
VALUES
  ('ТОВ «Галицька Кавова Мануфактура»',        '+380322401122', 'order@gal-coffee.example.ua',   'м. Львів, вул. Промислова, 45'),
  ('ПрАТ «Західноукраїнський Молочний Дім»',    '+380322998877', 'supply@westmilk.example.ua',    'м. Львів, вул. Городоцька, 280'),
  ('ТОВ «Еко-Рослинне Молоко Баріста»',        '+380443004455', 'b2b@baristaoat.example.ua',     'м. Київ, просп. Степана Бандери, 21'),
  ('ФОП Мельник А.В. (Овочева База Поділля)',  '+380671112233', 'melnyk.veggies@example.ua',   'м. Вінниця, вул. Складська, 3'),
  ('ТОВ «М’ясна Гільдія Преміум»',             '+380445556677', 'sales@meatguild.example.ua',     'м. Київ, вул. Бориспільська, 9'),
  ('ТОВ «Бакалія Трейд Захід»',                 '+380322334455', 'orders@bakalia-trade.example.ua','м. Львів, вул. Зелена, 149'),
  ('ТОВ «Нордік Фіш Україна»',                  '+380487008899', 'import@nordicfish.example.ua',   'м. Одеса, вул. Приморська, 40'),
  ('Італійський Торговий Дім «Оліва»',          '+380442228811', 'office@oliva-import.example.ua', 'м. Київ, вул. Межигірська, 19'),
  ('ПП «Карпатська Еко-Ферма»',                 '+380504321098', 'karpaty.eco@example.ua',         'Івано-Франківська обл., с. Поляниця'),
  ('ТОВ «Сирна Лабораторія Craft»',             '+380631234567', 'order@cheeselab.example.ua',     'м. Тернопіль, вул. Текстильна, 28');


-- ----------------------------------------------------------------
-- 3. INSERT: LOCATION_INVENTORY
-- ----------------------------------------------------------------
INSERT INTO location_inventory (location_id, ingredient_id, current_stock, min_stock_level)
VALUES
  -- Локація 1 (Lviv Central)
  (1, 1,  45.500,  15.000),  -- Кавове зерно
  (1, 2,  60.000,  20.000),  -- Молоко коров'яче
  (1, 3,  25.000,  10.000),  -- Молоко вівсяне
  (1, 6,  18.250,   5.000),  -- Масло
  (1, 12, 14.000,   4.000),  -- Сироп

  -- Локація 3 (Kyiv Khreshchatyk)
  (3, 1,  80.000,  30.000),  -- Кавове зерно
  (3, 2, 120.000,  40.000),  -- Молоко
  (3, 7,  45.000,  15.000),  -- Філе куряче
  (3, 8,  30.000,  10.000),  -- Моцарела
  (3, 10, 15.500,   5.000),  -- Лосось

  -- Локація 4 (Kyiv Podil)
  (4, 7,  28.000,  10.000),  -- Філе куряче
  (4, 9,  40.000,  15.000),  -- Томати
  (4, 11, 12.000,   4.000),  -- Олія оливкова

  -- Локація 6 (Odesa Lounge)
  (6, 1,  35.000,  12.000),  -- Кавове зерно
  (6, 10, 22.000,   8.000);  -- Лосось


-- ----------------------------------------------------------------
-- 4. INSERT: SUPPLIER_INGREDIENTS
-- ----------------------------------------------------------------
INSERT INTO supplier_ingredients (supplier_id, ingredient_id, purchase_price, effective_date)
VALUES
  (1, 1,  680.00, '2026-01-10'),  -- Кава (постачальник 1)
  (1, 1,  720.00, '2026-06-01'),  -- Кава (нова ціна з літа)
  (2, 2,   38.50, '2026-02-01'),  -- Молоко
  (3, 3,   74.00, '2026-01-15'),  -- Вівсяне молоко
  (6, 4,   22.00, '2026-03-01'),  -- Борошно
  (6, 5,   29.50, '2026-03-01'),  -- Цукор
  (2, 6,  310.00, '2026-02-15'),  -- Масло вершкове
  (5, 7,  185.00, '2026-04-01'),  -- Філе куряче
  (10, 8, 295.00, '2026-03-20'),  -- Моцарела
  (4, 9,   65.00, '2026-05-10'),  -- Томати
  (7, 10, 640.00, '2026-01-20'),  -- Лосось
  (8, 11, 420.00, '2026-02-10');  -- Оливкова олія


-- ----------------------------------------------------------------
-- 5. UPDATE SCENARIOS
-- ----------------------------------------------------------------

-- Сценарій 1: Прийом нової партії товару на склад у Києві (+20 кг кави)
UPDATE location_inventory
SET current_stock = current_stock + 20.000
WHERE location_id = 3 AND ingredient_id = 1;

-- Сценарій 2: Оновлення контактного номера телефону та адреси постачальника
UPDATE suppliers
SET phone = '+380322409999',
    address = 'м. Львів, вул. Богдана Хмельницького, 176'
WHERE supplier_id = 1;

-- Сценарій 3: Деактивація сезонного закладу (м'яке закриття, замість видалення)
UPDATE locations
SET is_active = false
WHERE location_id = 11;


-- ----------------------------------------------------------------
-- 6. DELETE SCENARIOS
-- ----------------------------------------------------------------

-- Видалення старої або скасованої цінової пропозиції з історії цін
DELETE FROM supplier_ingredients
WHERE supplier_id = 1 
  AND ingredient_id = 1 
  AND effective_date = '2026-01-10';


-- ----------------------------------------------------------------
-- 7. DEMONSTRATION OF CONSTRAINTS VALIDATION
-- (Всі запити закоментовані, щоб не зупиняти виконання скрипта)
-- ----------------------------------------------------------------

-- Перевірка CHECK (current_stock >= 0)
-- INSERT INTO location_inventory (location_id, ingredient_id, current_stock, min_stock_level) VALUES (1, 10, -5.000, 2.000);

-- Перевірка FOREIGN KEY
-- INSERT INTO location_inventory (location_id, ingredient_id, current_stock, min_stock_level) VALUES (9999, 1, 10.000, 2.000);

-- Спроба повторно вставити ціну на ту саму дату від того ж постачальника:
-- INSERT INTO supplier_ingredients (supplier_id, ingredient_id, purchase_price, effective_date) VALUES (2, 2, 40.00, '2026-02-01');

