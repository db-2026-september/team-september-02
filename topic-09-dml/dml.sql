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
-- delete from public.location_inventory; 
-- delete from public.supplier_ingredients; 
-- delete from public.suppliers; 
-- delete from public.shift_schedules; 
-- delete from public.staff; 
-- delete from public.order_items; 
-- delete from public.customer_feedback; 
-- delete from public.reservations; 
-- delete from public.restaurant_tables; 
-- delete from public.orders; 
-- delete from public.customers; 
-- delete from public.menu_item_ingredients; 
-- delete from public.locations; 
-- delete from public.ingredients;
-- delete from public.menu_items; 
-- delete from public.menu_categories; 


-- Maksym Soloviov рядки з 55 - 285
-- Vitaliy Fronts рядки 290 - 422
-- Oleksii Antypov 430 - 544
-- Valerii Kyrpychenko 550 - 869



/******************************************************************************
  DML — секція «Меню та страви»
  Автор: Maksym Soloviov
  Таблиці: menu_categories, ingredients, menu_items, menu_item_ingredients

  Порядок виконання: спочатку довідники (на них ніхто не посилається),
  потім таблиці із зовнішніми ключами.
******************************************************************************/

-- ============================================================================
-- 1. INSERT — наповнення таблиць
-- ============================================================================

-- 1.1 Категорії меню (довідник, заповнюється першим)
INSERT INTO menu_categories(category_id,name,description)
VALUES
(1,'Перші страви', 'Супи, борщі та бульйони'),
(2,'Основні страви','Гарячі страви з риби, птиці та свинини'),
(3,'Гарячі закуски','Теплі закуски до основної страви'),
(4,'Холодні закуски','Сирні та рибні нарізки, брускети'),
(5,'Десерти','Торти, тістечка та морозиво'),
(6,'Сніданки','Страви, які подаються до полудня'),
(7,'Салати','Свіжі овочеві та теплі салати'),
(8,'Гарніри','Каші, картопля та овочі до основних страв'),
(9,'Безалкогольні напої','Соки, лимонади, чай та кава'),
(10,'Алкогольні напої','Вино, пиво та міцні напої'),
(11,'Дитяче меню','Страви для маленьких гостей');

-- 1.2 Інгредієнти (довідник). Одиниці виміру: г / мл / шт
INSERT INTO ingredients(ingredient_id,name,unit)
VALUES
(1,'Картопля', 'г'),
(2,'Морква','г'),
(3,'Курятина','г'),
(4,'Свинина','г'),
(5,'Рис','г'),
(6,'Вермішель','г'),
(7,'Рибне філе','г'),
(8,'Сіль','г'),
(9,'Вершки','мл'),
(10,'Сметана','г'),
(11,'Чорний перець','г'),
(12,'Сухі спеції','г'),
(13,'Вода','мл'),
(14,'Рослинна олія','мл'),
(15,'Яйця','шт'),
(16,'Темний шоколад','г'),
(17,'Цукрова пудра','г'),
(18,'Полуниця','г'),
(19,'Мед','мл');

-- 1.3 Страви меню (посилаються на menu_categories через category_id).
--     Рибні страви (2, 7, 10) тимчасово недоступні — риба закінчилась.
INSERT INTO menu_items(menu_item_id,category_id,name,price,preparation_time_min,is_available)
VALUES
(1,1,'Курячий суп з вермішеллю', 350.00, 15,TRUE),
(2,1,'Рибна юшка',450,20,FALSE),
(3,1,'Картопляний крем-суп',300,15,TRUE),
(4,2,'Свинина запечена з картоплею',350,25,TRUE),
(5,2,'Плов зі свининою',300,25,TRUE),
(6,2,'Куряче філе у вершковому соусі',400,20,TRUE),
(7,2,'Смажене рибне філе',500,25,FALSE),
(8,3,'Курячі нагетси',200,10,TRUE),
(9,3,'Деруни зі сметаною',250,10,TRUE),
(10,2,'Рибні котлети',380,25,FALSE),
(11,6,'Яйця під сметанним соусом',220,10,TRUE),
(12,5,'Шоколадний фондан',200,5,TRUE),
(13,5,'Полуниця з вершками',240,5,TRUE),
(14,6,'Омлет з вершками',200,10,TRUE),
(15,6,'Рисова каша з медом',180,20,TRUE),
(16,7,'Морквяний салат зі сметаною',240,10,TRUE),
(17,8,'Картопляне пюре',200,20,TRUE),
(18,8,'Відварний рис',200,25,TRUE),
(19,9,'Гарячий шоколад',250,5,TRUE);

-- 1.4 Склад страв (посилається на menu_items та ingredients).
--     Один рядок = один інгредієнт у рецепті; quantity_demand — на одну порцію.
INSERT INTO menu_item_ingredients(menu_item_id,ingredient_id,quantity_demand)
VALUES
-- 1 Курячий суп з вермішеллю
(1,1,80),
(1,3,100),
(1,6,30),
(1,13,300),
(1,11,1),
-- 2 Рибна юшка
(2,7,120),
(2,1,100),
(2,2,40),
(2,13,300),
(2,8,3),
-- 3 Картопляний крем-суп
(3,1,200),
(3,9,80),
(3,13,200),
(3,8,3),
-- 4 Свинина запечена з картоплею
(4,4,200),
(4,1,250),
(4,12,5),
(4,14,15),
(4,8,4),
-- 5 Плов зі свининою
(5,5,120),
(5,4,150),
(5,2,60),
(5,14,20),
(5,12,4),
-- 6 Куряче філе у вершковому соусі
(6,3,180),
(6,9,100),
(6,11,2),
(6,8,3),
-- 7 Смажене рибне філе
(7,7,200),
(7,14,20),
(7,8,3),
(7,11,1),
-- 8 Курячі нагетси
(8,3,150),
(8,15,1),
(8,14,30),
(8,12,3),
-- 9 Деруни зі сметаною
(9,1,250),
(9,15,1),
(9,10,50),
(9,14,25),
(9,8,3),
-- 10 Рибні котлети
(10,7,180),
(10,15,1),
(10,14,20),
(10,8,3),
-- 11 Яйця під сметанним соусом
(11,15,2),
(11,10,60),
(11,11,1),
-- 12 Шоколадний фондан
(12,16,70),
(12,15,1),
(12,17,30),
-- 13 Полуниця з вершками
(13,18,150),
(13,9,80),
(13,17,15),
-- 14 Омлет з вершками
(14,15,3),
(14,9,50),
(14,8,2),
-- 15 Рисова каша з медом
(15,5,80),
(15,13,200),
(15,19,20),
-- 16 Морквяний салат зі сметаною
(16,2,150),
(16,10,40),
-- 17 Картопляне пюре
(17,1,250),
(17,9,50),
(17,8,3),
-- 18 Відварний рис
(18,5,100),
(18,13,200),
(18,8,2),
-- 19 Гарячий шоколад
(19,16,50),
(19,9,200);


-- ============================================================================
-- 2. UPDATE — оновлення даних
-- ============================================================================

-- 2.1 Подорожчали продукти для десертів: ціна всіх страв категорії 5 зростає на 10%
UPDATE menu_items
SET price = price * 1.1
WHERE category_id = 5;

-- 2.2 Привезли рибу: рибні страви знову доступні для замовлення
UPDATE menu_items
SET is_available = TRUE
WHERE menu_item_id IN(2,7,10);


-- ============================================================================
-- 3. DELETE — видалення даних
-- ============================================================================

-- 3.1 Ресторан не отримав ліцензію на алкоголь: видаляємо категорію без страв
DELETE FROM menu_categories
WHERE category_id = 10;

-- 3.2 Страву «Гарячий шоколад» прибрали з меню.
--     Спочатку видаляємо її склад (рядки, що посилаються на страву), потім саму страву.
DELETE FROM menu_item_ingredients
WHERE menu_item_id = 19;

DELETE FROM menu_items
WHERE menu_item_id = 19;

-- ============================================================================
-- 4. Перевірка обмежень цілісності (constraints)
--    Кожен запит нижче навмисно порушує правило і має завершитися помилкою,
--    тому вони закоментовані — інакше скрипт зупинився б.
--    Щоб перевірити, розкоментуйте та виконайте запит окремо.
-- ============================================================================

-- 4.1 UNIQUE: назва категорії не може повторюватися
-- INSERT INTO menu_categories(category_id,name,description)
-- VALUES (12,'Десерти','Дубль назви категорії');

-- 4.2 PRIMARY KEY: номер інгредієнта не може повторюватися
-- INSERT INTO ingredients(ingredient_id,name,unit)
-- VALUES (1,'Цибуля','г');

-- 4.3 FOREIGN KEY: страва не може посилатися на неіснуючу категорію
-- INSERT INTO menu_items(menu_item_id,category_id,name,price,preparation_time_min,is_available)
-- VALUES (20,99,'Тестова страва',100.00,10,TRUE);

-- 4.4 NOT NULL: страва не може бути без ціни
-- INSERT INTO menu_items(menu_item_id,category_id,name,preparation_time_min,is_available)
-- VALUES (21,1,'Страва без ціни',10,TRUE);

-- 4.5 CHECK: кількість інгредієнта має бути більшою за нуль
-- INSERT INTO menu_item_ingredients(menu_item_id,ingredient_id,quantity_demand)
-- VALUES (1,2,0);

-- 4.6 FOREIGN KEY при видаленні: не можна видалити страву, поки існує її склад
-- DELETE FROM menu_items
-- WHERE menu_item_id = 1;




/*******************************************************************
Vitaliy Fronts
*******************************************************************/
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
INSERT INTO suppliers (supplier_id, name, phone, email, address)
VALUES
  (1, 'ТОВ «Галицька Кавова Мануфактура»',        '+380322401122', 'order@gal-coffee.example.ua',   'м. Львів, вул. Промислова, 45'),
  (2, 'ПрАТ «Західноукраїнський Молочний Дім»',    '+380322998877', 'supply@westmilk.example.ua',    'м. Львів, вул. Городоцька, 280'),
  (3, 'ТОВ «Еко-Рослинне Молоко Баріста»',        '+380443004455', 'b2b@baristaoat.example.ua',     'м. Київ, просп. Степана Бандери, 21'),
  (4, 'ФОП Мельник А.В. (Овочева База Поділля)',  '+380671112233', 'melnyk.veggies@example.ua',   'м. Вінниця, вул. Складська, 3'),
  (5, 'ТОВ «М’ясна Гільдія Преміум»',             '+380445556677', 'sales@meatguild.example.ua',     'м. Київ, вул. Бориспільська, 9'),
  (6, 'ТОВ «Бакалія Трейд Захід»',                 '+380322334455', 'orders@bakalia-trade.example.ua','м. Львів, вул. Зелена, 149'),
  (7, 'ТОВ «Нордік Фіш Україна»',                  '+380487008899', 'import@nordicfish.example.ua',   'м. Одеса, вул. Приморська, 40'),
  (8, 'Італійський Торговий Дім «Оліва»',          '+380442228811', 'office@oliva-import.example.ua', 'м. Київ, вул. Межигірська, 19'),
  (9, 'ПП «Карпатська Еко-Ферма»',                 '+380504321098', 'karpaty.eco@example.ua',         'Івано-Франківська обл., с. Поляниця'),
  (10, 'ТОВ «Сирна Лабораторія Craft»',             '+380631234567', 'order@cheeselab.example.ua',     'м. Тернопіль, вул. Текстильна, 28');


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







-- ================================================================
-- SQL DML (TOPIC 09)
-- AUTHOR: Oleksii Antypov
-- ================================================================

INSERT INTO customers (customer_id, first_name, last_name, phone, email) values
(1, 'Анонім', 'Анонім', '+380509999999', 'anonim.anonim@example.com'),
(2,'Андрій', 'Шевченко', '+380671234102', 'andrii.shevchenko@example.com'),
(3,'Марія', 'Бондаренко', '+380931234103', 'mariia.bondarenko@example.com'),
(4,'Іван', 'Мельник', '+380991234104', 'ivan.melnyk@example.com'),
(5,'Наталія', 'Ткаченко', '+380631234105', 'nataliia.tkachenko@example.com'),
(6,'Дмитро', 'Кравченко', '+380501234106', 'dmytro.kravchenko@example.com'),
(7,'Софія', 'Олійник', '+380671234107', 'sofiia.oliinyk@example.com'),
(8,'Максим', 'Лисенко', '+380931234108', 'maksym.lysenko@example.com'),
(9,'Катерина', 'Петренко', '+380991234109', 'kateryna.petrenko@example.com'),
(10,'Тарас', 'Мороз', '+380631234110', 'taras.moroz@example.com');


INSERT INTO orders (order_id, order_number, location_id, customer_id, order_type, status, ordered_at, total_order_amount) values
(1, 20, 1, 1, 'DINE_IN', 'COMPLETED', '2004-10-02 10:23:54+02', 245.50),
(2, 50, 2, 2, 'DINE_IN', 'COMPLETED', '2026-10-02:16:20+02', 389.00),
(3, 60, 3, 3, 'DINE_IN', 'COMPLETED', '2026-10-02:18:05+02', 125.75),
(4, 100, 4, 4, 'DINE_IN', 'COMPLETED', '2026-10-03:12:10+02', 560.00),
(5, 150, 5, 5, 'TAKEAWAY', 'COMPLETED', '2026-10-03:15:12+02', 79.90),
(6, 15, 6, 6, 'DINE_IN', 'COMPLETED', '2026-10-03:16:54+02', 312.40),
(7, 25, 7, 7, 'TAKEAWAY', 'READY', '2026-10-04:09:25+02', 845.25),
(8, 80, 8, 8, 'DINE_IN', 'PREPARING', '2026-10-04:10:00+02',  199.99),
(9, 200, 9, 9, 'DINE_IN', 'PREPARING', '2026-10-04:10:30+02', 430.00),
(10, 5, 11, 10, 'TAKEAWAY', 'NEW', '2026-10-04:10:54+02', 150.00),
(11, 7, 11, 10, 'DINE_IN', 'NEW', '2027-10-04:10:54+02', 245.00);


INSERT INTO order_items (order_item_id, order_id, menu_item_id, quantity, item_price) values
(1, 1, 1, 1, 245.50),
(2, 2, 2, 1, 389.00),
(3, 3, 3, 1, 125.75),
(4, 4, 4, 2, 280.00),
(5, 5, 5, 1, 79.90),
(6, 6, 6, 2, 156.20),
(7, 7, 7, 1, 845.25),
(8, 8, 8, 1, 199.99),
(9, 9, 9, 2, 215.00),
(10, 10, 10, 3, 50.00),
(11, 11, 1, 1, 50.00);


INSERT INTO customer_feedback (feedback_id, customer_id, location_id, order_id, rating, comment, created_at) values
(1, 1, 1, 1, 4, 'Добре', '2004-10-03 10:23:54+02'),
(2, 2, 2, 2, 5, 'Дуже добре', '2026-10-03:16:20+02'),
(3, 3, 3, 3, 4, 'Смачно', '2026-10-03:18:05+02'),
(4, 4, 4, 4, 5, 'Добре', '2026-10-04:12:10+02'),
(5, 5, 5, 5, 4, 'Гарна атмосфера', '2026-10-04:15:12+02'),
(6, 6, 6, 6, 5, 'Файно', '2026-10-04:16:54+02'),
(7, 7, 7, 7, 4, 'Чюдово', '2026-10-05:09:25+02'),
(8, 8, 8, 8, 5, 'Добре', '2026-10-05:10:00+02'),
(9, 9, 9, 9, 4, 'Спадобалось', '2026-10-05:10:30+02'),
(10, 10, 11, 10, 5, 'Дуже добре', '2026-10-05:10:54+02');

INSERT INTO restaurant_tables (location_id, table_number, seats_count) values
(1, 1, 5),
(2, 1, 4),
(3, 1, 6),
(4, 1, 5),
(5, 1, 5),
(6, 1, 6),
(7, 1, 7),
(8, 1, 5),
(9, 1, 4),
(10, 1, 4);

INSERT INTO reservations (reservation_id, location_id, customer_id, table_number, reservation_datetime, guests_count, status) values
(1, 1, 1, 1, '2004-10-02 10:23:54+02', 5, 'Reserved'),
(2, 2, 2, 1, '2026-10-02:16:20+02', 3, 'Reserved'),
(3, 3, 3, 1, '2026-10-02:18:05+02', 5, 'Reserved'),
(4, 4, 4, 1, '2026-10-03:12:10+02', 5, 'Reserved'),
(5, 5, 5, 1, '2026-10-03:15:12+02', 4, 'Reserved'),
(6, 6, 6, 1, '2026-10-03:16:54+02', 5, 'Reserved'),
(7, 7, 7, 1, '2026-10-04:09:25+02', 6, 'Reserved'),
(8, 8, 8, 1, '2026-10-04:10:00+02', 3, 'Reserved'),
(9, 9, 9, 1, '2026-10-04:10:30+02', 4, 'Reserved'),
(10, 10, 10, 1, '2026-10-04:10:54+02', 3, 'Reserved');


-- ----------------------------------------------------------------
-- UPDATE/DELETE
-- ----------------------------------------------------------------
-- Оновлення телефона клієнта
update public.customers
set phone = '+380507878785'
where customer_id = 1;

-- Оновлення статусу замовлення
update public.orders
set status = 'READY'
where order_id = 8;

-- Внесення змін у замовлення
update order_items
set menu_item_id = 9,
    quantity = 2,
    item_price = 215.00
where order_id = 10;

-- Оновлення вартості замовлення після внесення змін у замовлення
update orders
set total_order_amount = 430
where order_id = 10;

-- Видалення замовлення у разі скасування клієнтом
delete from public.order_items
where order_id = 11;

-- Видалення замовлення у разі скасування клієнтом
delete from public.orders
where order_id = 11;





-- ================================================================
-- SQL DML (TOPIC 09) — СЕКЦІЯ: ПЕРСОНАЛ ТА ГРАФІКИ РОБОТИ
-- AUTHOR: Valerii Kyrpychenko
-- Таблиці: staff, shift_schedules
-- ================================================================
-- Залежності: таблиця locations має бути заповнена (секція 1).
-- location_id 1..11 відповідають порядку вставки локацій.
-- Часовий пояс: Україна, літній час (EEST, +03).
-- ================================================================


-- ----------------------------------------------------------------
-- 8.1 INSERT: STAFF
-- Поле staff_id генерується автоматично (bigserial).
-- Дані анонімізовані: вигадані ПІБ, телефони та e-mail у домені example.
-- ----------------------------------------------------------------
INSERT INTO staff (location_id, first_name, last_name, middle_name, birth_date, position, phone, email, is_active)
VALUES
  (1,  'Олена',    'Коваль',     'Ігорівна',       '1996-04-12', 'Бариста',          '+380671000001', 'olena.koval@staff.example.ua',        true),
  (1,  'Андрій',   'Шевчук',     'Петрович',       '1988-09-03', 'Менеджер закладу', '+380671000002', 'andrii.shevchuk@staff.example.ua',    true),
  (2,  'Ірина',    'Бондаренко', 'Василівна',      '1999-01-25', 'Пекар',            '+380671000003', 'iryna.bondarenko@staff.example.ua',   true),
  (3,  'Максим',   'Ткаченко',   'Олегович',       '1985-06-17', 'Шеф-кухар',        '+380671000004', 'maksym.tkachenko@staff.example.ua',   true),
  (3,  'Софія',    'Мельник',    NULL,             '2001-11-30', 'Офіціант',         '+380671000005', 'sofiia.melnyk@staff.example.ua',      true),  -- по батькові необов'язкове
  (4,  'Дмитро',   'Кравченко',  'Сергійович',     '1993-02-08', 'Кухар',            '+380671000006', 'dmytro.kravchenko@staff.example.ua',  true),
  (5,  'Наталія',  'Олійник',    'Андріївна',      '1990-07-21', 'Адміністратор',    '+380671000007', 'nataliia.oliinyk@staff.example.ua',   true),
  (6,  'Тарас',    'Лисенко',    'Миколайович',    '1997-03-14', 'Бариста',          '+380671000008', 'taras.lysenko@staff.example.ua',      true),
  (7,  'Юлія',     'Савченко',   'Олександрівна',  '1994-10-02', 'Су-шеф',           '+380671000009', 'yuliia.savchenko@staff.example.ua',   true),
  (8,  'Богдан',   'Руденко',    'Іванович',       '2000-05-19', 'Офіціант',         '+380671000010', 'bohdan.rudenko@staff.example.ua',     true),
  (9,  'Христина', 'Марченко',   'Романівна',      '1998-08-09', 'Бариста',          '+380671000011', 'khrystyna.marchenko@staff.example.ua', true),
  (10, 'Віктор',   'Павленко',   'Степанович',     '1991-12-27', 'Кухар',            '+380671000012', 'viktor.pavlenko@staff.example.ua',    true),
  (11, 'Остап',    'Гнатюк',     'Ярославович',    '2002-03-03', 'Бариста',          '+380671000013', 'ostap.hnatiuk@staff.example.ua',      true);  -- сезонний заклад, буде звільнений (див. 8.3)


-- ----------------------------------------------------------------
-- 8.2 INSERT: SHIFT_SCHEDULES
-- staff_id та location_id беремо через JOIN по e-mail працівника,
-- а не "жорсткими" числами — так скрипт не залежить від значень bigserial.
-- Логіка статусів:
--   COMPLETED   -> заповнені actual_start_time і actual_end_time
--   IN_PROGRESS -> заповнений лише actual_start_time
--   SCHEDULED / NO_SHOW / CANCELLED -> фактичний час відсутній
-- Перший рядок VALUES містить явні приведення типів (::timestamptz,
-- ::shift_status), щоб PostgreSQL правильно визначив типи стовпців.
-- ----------------------------------------------------------------
INSERT INTO shift_schedules (location_id, staff_id, start_time, end_time, actual_start_time, actual_end_time, break_time_minutes, status)
SELECT s.location_id, s.staff_id, v.start_time, v.end_time, v.actual_start, v.actual_end, v.break_min, v.status
FROM (
  VALUES
    -- Завершені зміни (минулий тиждень)
    ('olena.koval@staff.example.ua',
        '2026-09-28 07:30+03'::timestamptz, '2026-09-28 16:00+03'::timestamptz,
        '2026-09-28 07:25+03'::timestamptz, '2026-09-28 16:05+03'::timestamptz, 30, 'COMPLETED'::shift_status),
    ('olena.koval@staff.example.ua',
        '2026-09-29 07:30+03', '2026-09-29 16:00+03', '2026-09-29 07:40+03', '2026-09-29 16:00+03', 30, 'COMPLETED'),  -- запізнення на 10 хв
    ('andrii.shevchuk@staff.example.ua',
        '2026-09-28 09:00+03', '2026-09-28 18:00+03', '2026-09-28 08:55+03', '2026-09-28 18:20+03', 60, 'COMPLETED'),
    ('iryna.bondarenko@staff.example.ua',
        '2026-09-30 05:00+03', '2026-09-30 13:00+03', '2026-09-30 05:00+03', '2026-09-30 13:10+03', 30, 'COMPLETED'),  -- рання зміна пекаря
    ('maksym.tkachenko@staff.example.ua',
        '2026-10-01 10:00+03', '2026-10-01 22:00+03', '2026-10-01 09:50+03', '2026-10-01 22:15+03', 60, 'COMPLETED'),
    ('dmytro.kravchenko@staff.example.ua',
        '2026-10-02 11:00+03', '2026-10-02 20:00+03', '2026-10-02 11:05+03', '2026-10-02 20:00+03', 45, 'COMPLETED'),
    ('taras.lysenko@staff.example.ua',
        '2026-10-03 08:00+03', '2026-10-03 16:00+03', '2026-10-03 07:58+03', '2026-10-03 16:02+03', 30, 'COMPLETED'),
    ('ostap.hnatiuk@staff.example.ua',
        '2026-09-27 10:00+03', '2026-09-27 18:00+03', '2026-09-27 09:55+03', '2026-09-27 18:00+03', 30, 'COMPLETED'),  -- остання зміна в сезонному закладі

    -- Неявка та скасування
    ('sofiia.melnyk@staff.example.ua',
        '2026-10-01 12:00+03', '2026-10-01 21:00+03', NULL, NULL, 0, 'NO_SHOW'),
    ('nataliia.oliinyk@staff.example.ua',
        '2026-10-03 08:00+03', '2026-10-03 17:00+03', NULL, NULL, 0, 'CANCELLED'),

    -- Поточні зміни (зараз на роботі)
    ('yuliia.savchenko@staff.example.ua',
        '2026-10-04 09:00+03', '2026-10-04 18:00+03', '2026-10-04 08:57+03', NULL, 0, 'IN_PROGRESS'),
    ('bohdan.rudenko@staff.example.ua',
        '2026-10-04 10:00+03', '2026-10-04 19:00+03', '2026-10-04 10:03+03', NULL, 0, 'IN_PROGRESS'),

    -- Заплановані зміни (наступні дні)
    ('khrystyna.marchenko@staff.example.ua',
        '2026-10-05 07:00+03', '2026-10-05 15:00+03', NULL, NULL, 0, 'SCHEDULED'),
    ('viktor.pavlenko@staff.example.ua',
        '2026-10-05 11:00+03', '2026-10-05 20:00+03', NULL, NULL, 0, 'SCHEDULED'),
    ('olena.koval@staff.example.ua',
        '2026-10-06 07:30+03', '2026-10-06 16:00+03', NULL, NULL, 0, 'SCHEDULED'),
    ('sofiia.melnyk@staff.example.ua',
        '2026-10-06 12:00+03', '2026-10-06 21:00+03', NULL, NULL, 0, 'SCHEDULED'),
    ('ostap.hnatiuk@staff.example.ua',
        '2026-10-10 10:00+03', '2026-10-10 18:00+03', NULL, NULL, 0, 'SCHEDULED'),  -- буде скасована при звільненні
    ('dmytro.kravchenko@staff.example.ua',
        '2026-10-07 11:00+03', '2026-10-07 20:00+03', NULL, NULL, 0, 'SCHEDULED')   -- помилково створена, буде видалена (див. 8.4)
) AS v(email, start_time, end_time, actual_start, actual_end, break_min, status)
JOIN staff s ON s.email = v.email;


-- ----------------------------------------------------------------
-- 8.3 UPDATE SCENARIOS
-- ----------------------------------------------------------------

-- Сценарій 1: Завершення поточної зміни — фіксуємо фактичний час виходу,
-- перерву та переводимо статус IN_PROGRESS -> COMPLETED.
UPDATE shift_schedules
SET actual_end_time    = '2026-10-04 18:05+03',
    break_time_minutes = 45,
    status             = 'COMPLETED'
WHERE staff_id = (SELECT staff_id FROM staff WHERE email = 'yuliia.savchenko@staff.example.ua')
  AND start_time = '2026-10-04 09:00+03'
  AND status = 'IN_PROGRESS';

-- Сценарій 2: Перенесення запланованої зміни на годину пізніше.
UPDATE shift_schedules
SET start_time = start_time + INTERVAL '1 hour',
    end_time   = end_time   + INTERVAL '1 hour'
WHERE staff_id = (SELECT staff_id FROM staff WHERE email = 'viktor.pavlenko@staff.example.ua')
  AND start_time = '2026-10-05 11:00+03'
  AND status = 'SCHEDULED';

-- Сценарій 3: Працівник змінив номер телефону.
UPDATE staff
SET phone = '+380631000005'
WHERE email = 'sofiia.melnyk@staff.example.ua';

-- Сценарій 4: Переведення працівника в іншу локацію (Одеса -> Київ, Хрещатик).
UPDATE staff
SET location_id = 3
WHERE email = 'taras.lysenko@staff.example.ua';

-- Сценарій 5: Звільнення працівника сезонного закладу (м'яке видалення).
-- Запис у staff зберігається для історії змін та нарахування зарплати,
-- а всі його майбутні заплановані зміни скасовуються.
UPDATE staff
SET is_active = false
WHERE email = 'ostap.hnatiuk@staff.example.ua';

UPDATE shift_schedules
SET status = 'CANCELLED'
WHERE staff_id = (SELECT staff_id FROM staff WHERE email = 'ostap.hnatiuk@staff.example.ua')
  AND status = 'SCHEDULED';


-- ----------------------------------------------------------------
-- 8.4 DELETE SCENARIOS
-- ----------------------------------------------------------------

-- Видалення зміни, створеної помилково. Видаляємо лише ту, що ще
-- не розпочалася (SCHEDULED, без фактичного часу) — історію не чіпаємо.
DELETE FROM shift_schedules
WHERE staff_id = (SELECT staff_id FROM staff WHERE email = 'dmytro.kravchenko@staff.example.ua')
  AND start_time = '2026-10-07 11:00+03'
  AND status = 'SCHEDULED'
  AND actual_start_time IS NULL;

-- Чому DELETE не застосовується до staff:
--   на працівника посилаються записи shift_schedules (FOREIGN KEY), вони
--   потрібні для обліку відпрацьованих годин і зарплати. Тому замість
--   видалення використовується is_active = false (див. сценарій 5).
-- Чому не видаляються COMPLETED / NO_SHOW / CANCELLED зміни:
--   це історичні дані (облік часу, дисципліна), їх змінюють лише через UPDATE.


-- ----------------------------------------------------------------
-- 8.5 ПЕРЕВІРКА CONSTRAINTS
-- Кожен тест виконується в окремому DO-блоці: очікувана помилка
-- перехоплюється і виводиться як NOTICE, тому скрипт не зупиняється.
-- Якщо обмеження НЕ спрацювало, блок генерує власну помилку, яка
-- відкочує тестовий запис і виводить [FAIL].
-- ----------------------------------------------------------------

-- Тест 1: UNIQUE(phone) — повторний номер телефону
DO $$
BEGIN
  INSERT INTO staff (location_id, first_name, last_name, birth_date, position, phone, email)
  VALUES (1, 'Тест', 'Телефон', '1995-01-01', 'Бариста', '+380671000001', 'test.phone@staff.example.ua');
  RAISE EXCEPTION 'not triggered';
EXCEPTION
  WHEN unique_violation THEN RAISE NOTICE '[OK] UNIQUE(phone): %', SQLERRM;
  WHEN raise_exception  THEN RAISE NOTICE '[FAIL] UNIQUE(phone) не спрацював';
END $$;

-- Тест 2: UNIQUE(email) — повторний e-mail
DO $$
BEGIN
  INSERT INTO staff (location_id, first_name, last_name, birth_date, position, phone, email)
  VALUES (1, 'Тест', 'Пошта', '1995-01-01', 'Бариста', '+380679999999', 'olena.koval@staff.example.ua');
  RAISE EXCEPTION 'not triggered';
EXCEPTION
  WHEN unique_violation THEN RAISE NOTICE '[OK] UNIQUE(email): %', SQLERRM;
  WHEN raise_exception  THEN RAISE NOTICE '[FAIL] UNIQUE(email) не спрацював';
END $$;

-- Тест 3: FOREIGN KEY — неіснуюча локація
DO $$
BEGIN
  INSERT INTO staff (location_id, first_name, last_name, birth_date, position, phone, email)
  VALUES (9999, 'Тест', 'Локація', '1995-01-01', 'Бариста', '+380679999998', 'test.fk@staff.example.ua');
  RAISE EXCEPTION 'not triggered';
EXCEPTION
  WHEN foreign_key_violation THEN RAISE NOTICE '[OK] FK staff.location_id: %', SQLERRM;
  WHEN raise_exception       THEN RAISE NOTICE '[FAIL] FK staff.location_id не спрацював';
END $$;

-- Тест 4: NOT NULL — відсутня дата народження
DO $$
BEGIN
  INSERT INTO staff (location_id, first_name, last_name, position, phone, email)
  VALUES (1, 'Тест', 'Бездати', 'Бариста', '+380679999997', 'test.null@staff.example.ua');
  RAISE EXCEPTION 'not triggered';
EXCEPTION
  WHEN not_null_violation THEN RAISE NOTICE '[OK] NOT NULL(birth_date): %', SQLERRM;
  WHEN raise_exception    THEN RAISE NOTICE '[FAIL] NOT NULL(birth_date) не спрацював';
END $$;

-- Тест 5: chk_shift_time — кінець зміни раніше за початок
DO $$
BEGIN
  INSERT INTO shift_schedules (location_id, staff_id, start_time, end_time)
  SELECT location_id, staff_id, '2026-10-20 18:00+03', '2026-10-20 09:00+03'
  FROM staff WHERE email = 'olena.koval@staff.example.ua';
  RAISE EXCEPTION 'not triggered';
EXCEPTION
  WHEN check_violation THEN RAISE NOTICE '[OK] chk_shift_time: %', SQLERRM;
  WHEN raise_exception THEN RAISE NOTICE '[FAIL] chk_shift_time не спрацював';
END $$;

-- Тест 6: chk_actual_time_consistency — є фактичний кінець, але немає фактичного початку
DO $$
BEGIN
  INSERT INTO shift_schedules (location_id, staff_id, start_time, end_time, actual_end_time)
  SELECT location_id, staff_id, '2026-10-21 09:00+03', '2026-10-21 18:00+03', '2026-10-21 18:00+03'
  FROM staff WHERE email = 'olena.koval@staff.example.ua';
  RAISE EXCEPTION 'not triggered';
EXCEPTION
  WHEN check_violation THEN RAISE NOTICE '[OK] chk_actual_time_consistency (без початку): %', SQLERRM;
  WHEN raise_exception THEN RAISE NOTICE '[FAIL] chk_actual_time_consistency (без початку) не спрацював';
END $$;

-- Тест 7: chk_actual_time_consistency — фактичний кінець раніше за фактичний початок
DO $$
BEGIN
  INSERT INTO shift_schedules (location_id, staff_id, start_time, end_time, actual_start_time, actual_end_time)
  SELECT location_id, staff_id, '2026-10-22 09:00+03', '2026-10-22 18:00+03',
         '2026-10-22 18:00+03', '2026-10-22 09:00+03'
  FROM staff WHERE email = 'olena.koval@staff.example.ua';
  RAISE EXCEPTION 'not triggered';
EXCEPTION
  WHEN check_violation THEN RAISE NOTICE '[OK] chk_actual_time_consistency (кінець < початку): %', SQLERRM;
  WHEN raise_exception THEN RAISE NOTICE '[FAIL] chk_actual_time_consistency (кінець < початку) не спрацював';
END $$;

-- Тест 8: CHECK(break_time_minutes >= 0) — від'ємна перерва
DO $$
BEGIN
  INSERT INTO shift_schedules (location_id, staff_id, start_time, end_time, break_time_minutes)
  SELECT location_id, staff_id, '2026-10-23 09:00+03', '2026-10-23 18:00+03', -15
  FROM staff WHERE email = 'olena.koval@staff.example.ua';
  RAISE EXCEPTION 'not triggered';
EXCEPTION
  WHEN check_violation THEN RAISE NOTICE '[OK] CHECK(break_time_minutes >= 0): %', SQLERRM;
  WHEN raise_exception THEN RAISE NOTICE '[FAIL] CHECK(break_time_minutes) не спрацював';
END $$;

-- Тест 9: ENUM shift_status — неіснуючий статус
DO $$
BEGIN
  INSERT INTO shift_schedules (location_id, staff_id, start_time, end_time, status)
  SELECT location_id, staff_id, '2026-10-24 09:00+03', '2026-10-24 18:00+03', 'ON_BREAK'
  FROM staff WHERE email = 'olena.koval@staff.example.ua';
  RAISE EXCEPTION 'not triggered';
EXCEPTION
  WHEN invalid_text_representation THEN RAISE NOTICE '[OK] ENUM shift_status: %', SQLERRM;
  WHEN raise_exception             THEN RAISE NOTICE '[FAIL] ENUM shift_status не спрацював';
END $$;

-- Тест 10: uq_shift_staff_slot — дві зміни одного працівника з однаковим часом початку
DO $$
BEGIN
  INSERT INTO shift_schedules (location_id, staff_id, start_time, end_time)
  SELECT location_id, staff_id, '2026-09-28 07:30+03', '2026-09-28 12:00+03'
  FROM staff WHERE email = 'olena.koval@staff.example.ua';
  RAISE EXCEPTION 'not triggered';
EXCEPTION
  WHEN unique_violation THEN RAISE NOTICE '[OK] uq_shift_staff_slot: %', SQLERRM;
  WHEN raise_exception  THEN RAISE NOTICE '[FAIL] uq_shift_staff_slot не спрацював';
END $$;

-- Тест 11: FOREIGN KEY — неможливо видалити працівника, у якого є зміни
DO $$
BEGIN
  DELETE FROM staff WHERE email = 'andrii.shevchuk@staff.example.ua';
  RAISE EXCEPTION 'not triggered';
EXCEPTION
  WHEN foreign_key_violation THEN RAISE NOTICE '[OK] FK shift_schedules.staff_id захищає історію: %', SQLERRM;
  WHEN raise_exception       THEN RAISE NOTICE '[FAIL] працівника зі змінами вдалося видалити';
END $$;


-- ----------------------------------------------------------------
-- 8.6 КОНТРОЛЬНІ ЗАПИТИ (перевірка результату)
-- ----------------------------------------------------------------

-- Графік змін з фактично відпрацьованими годинами (за вирахуванням перерви)
SELECT l.name                              AS location,
       st.last_name || ' ' || st.first_name AS employee,
       st.position,
       sh.start_time,
       sh.end_time,
       sh.status,
       ROUND((EXTRACT(EPOCH FROM (sh.actual_end_time - sh.actual_start_time)) / 3600
              - sh.break_time_minutes / 60.0)::numeric, 2) AS worked_hours
FROM shift_schedules sh
JOIN staff     st ON st.staff_id    = sh.staff_id
JOIN locations l  ON l.location_id  = sh.location_id
ORDER BY sh.start_time;

-- Кількість змін за статусами
SELECT status, COUNT(*) AS shifts
FROM shift_schedules
GROUP BY status
ORDER BY status;


select 'Data was inserted successfully !!!';
