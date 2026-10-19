-- ================================================================
-- DATABASE ADMINISTRATION TEMPLATE (TOPIC 11)
-- ================================================================
-- WHAT SHOULD BE ADDED HERE:
-- 1) CREATE ROLE statements for at least 2 distinct roles.
--    Example roles: read-only analyst, read-write editor.
--
-- 2) GRANT statements assigning appropriate permissions to each role:
--    - Read-only role: GRANT SELECT ON ALL TABLES IN SCHEMA ...
--    - Read-write role: GRANT SELECT, INSERT, UPDATE, DELETE ...
--
-- 3) CREATE USER statements for at least 2 users.
--    Each user must be assigned to one of the defined roles.
--
-- 4) Comments before each section explaining the rationale:
--    - Why this role exists
--    - What access it should and should not have
--
-- RECOMMENDED ORDER:
-- 1) Roles + their GRANTs
-- 2) Users + GRANT ROLE TO USER
-- 3) Optional: REVOKE statements for fine-grained restrictions
-- 4) Optional cleanup block (commented out by default):
--    -- DROP USER ...; DROP ROLE ...;
--
-- IMPORTANT:
-- - Use explicit GRANT / REVOKE statements — do not rely on defaults.
-- - Roles must have meaningfully different permission levels.
-- - Script must execute in PostgreSQL without errors.
-- ================================================================

-- Add your script below this line

/******************************************************************************
  DATABASE ADMINISTRATION & ACCESS CONTROL (TOPIC 11)
  Проєкт: Restaurant Management System
  Спільний командний внесок:
    - Maksym Soloviov (Меню та страви: ролі only_read / read_and_write)
    - Віталій Фронц (Аналітика даних та загальний шаблон адміністрування)
    - Oleksii Antypov (Управління замовленнями та розробка / developer роль)
    - Valerii Kyrpychenko (Операційний персонал / керування змінами та DO-тести)
******************************************************************************/


-- ============================================================================
-- 0. ОЧИЩЕННЯ ТЕСТОВИХ ДАНИХ (Закоментовано за замовчуванням)
-- ============================================================================
/*
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM analytics_role, staff_role, developer, bi_user;
REVOKE USAGE ON SCHEMA public FROM analytics_role, staff_role, developer, bi_user;

DROP USER IF EXISTS analyst_user_1;
DROP USER IF EXISTS staff_user_1;
DROP USER IF EXISTS aleksey;
DROP USER IF EXISTS oksana;
DROP USER IF EXISTS Dima;
DROP USER IF EXISTS James;

DROP ROLE IF EXISTS analytics_role;
DROP ROLE IF EXISTS staff_role;
DROP ROLE IF EXISTS developer;
DROP ROLE IF EXISTS bi_user;
DROP ROLE IF EXISTS only_read;
DROP ROLE IF EXISTS read_and_write;
*/


-- ============================================================================
-- 1. СТВОРЕННЯ РОЛЕЙ (Спільна логіка розподілу обов'язків)
-- ============================================================================

-- Роль для розробників / повного доступу до керування структурою та даними (Oleksii Antypov)
CREATE ROLE developer NOLOGIN;

-- Роль бізнес-аналітики для перегляду звітів і замовлень (Oleksii Antypov / Віталій Фронц)
CREATE ROLE bi_user NOLOGIN;

-- Роль загального читання меню (Maksym Soloviov)
CREATE ROLE only_read NOLOGIN;

-- Роль редагування меню та операцій (Maksym Soloviov)
CREATE ROLE read_and_write NOLOGIN;

-- Роль операційного персоналу для планування змін і перегляду довідників (Valerii Kyrpychenko)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'staff_role') THEN
        CREATE ROLE staff_role NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE;
    END IF;
END
$$;

COMMENT ON ROLE staff_role IS 'Операційне керування змінами: читання довідників, INSERT/UPDATE змін. Без DELETE, без замовлень і клієнтів.';

-- Аналітична роль для доступу до операційних даних та звітів без прав модифікації (Віталій Фронц)
CREATE ROLE analytics_role NOLOGIN;


-- ============================================================================
-- 2. СТВОРЕННЯ КОРИСТУВАЧІВ ТА ПРИЗНАЧЕННЯ РОЛЕЙ
-- ============================================================================

-- Користувачі розробки та бізнес-аналітики (Oleksii Antypov)
CREATE USER aleksey WITH PASSWORD 'a123456';
GRANT developer TO aleksey;

CREATE USER oksana WITH PASSWORD 'o654321';
GRANT bi_user TO oksana;

-- Користувачі меню (Maksym Soloviov)
CREATE USER Dima WITH PASSWORD 'Dima_pass';
GRANT only_read TO Dima;

CREATE USER James WITH PASSWORD 'James_pass';
GRANT read_and_write TO James;

-- Користувачі аналітики та персоналу (Віталій Фронц, Valerii Kyrpychenko)
CREATE USER analyst_user_1 WITH PASSWORD 'analyst_password_2026';
GRANT analytics_role TO analyst_user_1;

CREATE USER staff_user_1 WITH PASSWORD 'staff_password_2026';
GRANT staff_role TO staff_user_1;


-- ============================================================================
-- 3. НАДАННЯ ПРАВ ДОСТУПУ (ПРИНЦИП МІНІМАЛЬНИХ ПРИВІЛЕЇВ)
-- ============================================================================

-- 3.1. Права для схеми public
GRANT USAGE ON SCHEMA public TO bi_user, developer, analytics_role, staff_role;

-- 3.2. Права на таблицю замовлень (orders) — Oleksii Antypov
GRANT SELECT ON orders TO bi_user;
GRANT ALL ON orders TO developer;
REVOKE REFERENCES, TRIGGER, TRUNCATE ON orders FROM developer;

-- 3.3. Права на таблицю меню (menu_items) — Maksym Soloviov
GRANT SELECT ON menu_items TO only_read;
GRANT SELECT, UPDATE, INSERT ON menu_items TO read_and_write;
-- DELETE навмисно не видано, щоб не руйнувати зв'язки зі складниками

-- 3.4. Права для аналітичної ролі (analytics_role) — Віталій Фронц
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analytics_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO analytics_role;

-- 3.5. Права для операційного персоналу (staff_role) — Valerii Kyrpychenko
-- Довідкові дані
GRANT SELECT ON locations, menu_categories, menu_items TO staff_role;

-- Персональні дані колег захищено: видаємо доступ лише до безпечних стовпців таблиці staff
GRANT SELECT (staff_id, location_id, first_name, last_name, position, is_active)
    ON TABLE staff TO staff_role;

-- Повне керування власними графіками змін (читання та створення)
GRANT SELECT, INSERT ON TABLE shift_schedules TO staff_role;

-- Редагування окремих полів розкладу (виключаючи первинний ключ для збереження цілісності)
GRANT UPDATE (location_id, staff_id, start_time, end_time,
              actual_start_time, actual_end_time, break_time_minutes, status)
    ON TABLE shift_schedules TO staff_role;

-- Надання прав на послідовність для вставки нових змін
DO $$
BEGIN
    EXECUTE format('GRANT USAGE ON SEQUENCE %s TO staff_role',
                   pg_get_serial_sequence('public.shift_schedules', 'shift_id'));
END
$$;


-- ============================================================================
-- 4. ЖОРСТКЕ ОБМЕЖЕННЯ ПРАВ (REVOKE)
-- ============================================================================

-- Заборона загального доступу для PUBLIC на критичні таблиці
REVOKE ALL ON menu_items FROM PUBLIC;

-- Обмеження для аналітиків та персоналу (захист від випадкових модифікацій)
REVOKE INSERT, UPDATE, DELETE ON customers, customer_feedback FROM analytics_role;
REVOKE UPDATE, DELETE ON orders, order_items FROM staff_role;
REVOKE DELETE, TRUNCATE ON TABLE shift_schedules FROM staff_role;
REVOKE ALL ON TABLE orders, order_items, customers, customer_feedback, reservations FROM staff_role;


-- ============================================================================
-- 5. АВТОМАТИЧНІ ТЕСТИ ПРАВ (DO-БЛОК ПЕРЕВІРКИ)
-- ============================================================================
-- Перевірка коректності налаштування прав для операційного персоналу (Valerii Kyrpychenko)
DO $$
DECLARE
    t         record;
    v_outcome text;
    v_total   int := 0;
    v_failed  int := 0;
BEGIN
    FOR t IN
        SELECT * FROM (VALUES
            ('staff_user_1', $q$SELECT * FROM shift_schedules LIMIT 1$q$,
                'ALLOWED', 'персонал може читати shift_schedules'),
            ('staff_user_1', $q$SELECT first_name, last_name, position FROM staff$q$,
                'ALLOWED', 'персонал може читати імена та посади колег'),
            ('staff_user_1', $q$SELECT birth_date FROM staff$q$,
                'DENIED',  'персонал не може читати персональні дані колег'),
            ('staff_user_1', $q$SELECT * FROM orders$q$,
                'DENIED',  'персонал не може читати замовлення'),
            ('staff_user_1', $q$SELECT * FROM customers$q$,
                'DENIED',  'персонал не може читати дані клієнтів')
        ) AS x(usr, stmt, expected, descr)
    LOOP
        v_total   := v_total + 1;
        v_outcome := NULL;

        BEGIN
            EXECUTE format('SET LOCAL ROLE %I', t.usr);
            EXECUTE t.stmt;
            v_outcome := 'ALLOWED';
            RAISE EXCEPTION 'відкат тесту' USING ERRCODE = 'RB001';
        EXCEPTION
            WHEN SQLSTATE 'RB001' THEN
                NULL;
            WHEN insufficient_privilege THEN
                v_outcome := 'DENIED';
            WHEN OTHERS THEN
                IF SQLSTATE LIKE '23%' THEN
                    v_outcome := 'ALLOWED';
                ELSE
                    v_outcome := 'ПОМИЛКА: ' || SQLERRM;
                END IF;
        END;

        IF v_outcome = t.expected THEN
            RAISE NOTICE '[PASS] #% %: % -> %', v_total, t.usr, t.descr, v_outcome;
        ELSE
            v_failed := v_failed + 1;
            RAISE NOTICE '[FAIL] #% %: % -> очікувалось %, отримано %',
                         v_total, t.usr, t.descr, t.expected, v_outcome;
        END IF;
    END LOOP;

    RAISE NOTICE 'Тести прав завершено: % успішних, % невдалих', v_total - v_failed, v_failed;

    IF v_failed > 0 THEN
        RAISE EXCEPTION 'Не пройдено тестів прав: %', v_failed;
    END IF;
END
$$;
