-- ================================================================
-- АДМІНІСТРУВАННЯ БАЗИ ДАНИХ (ТЕМА 11) - ЧАСТИНА: ПЕРСОНАЛ / КЕРУВАННЯ ЗМІНАМИ
-- Проєкт: Restaurant Management System
--
-- Valerii Kyrpychenko - права для операційного персоналу (зміни,
--                       графіки, доступ до shift_schedules) та
--                       тестування прав доступу за допомогою DO-блоків
--
-- ЯК ЗАПУСТИТИ
--   Спочатку виконайте DDL-скрипт (тема 04), потім цей скрипт, підключившись
--   до бази даних проєкту як суперкористувач (потрібно для CREATE ROLE та
--   SET ROLE). Скрипт можна безпечно запускати повторно.
--
-- ЛОГІКА ПРАВ ДОСТУПУ
--   staff_role = операційне керування змінами:
--     + читає довідкові дані (locations, меню)
--     + читає імена та посади колег (БЕЗ персональних даних)
--     + планує зміни (INSERT) і редагує їх (UPDATE, крім первинного ключа)
--     - не може видаляти (DELETE / TRUNCATE) зміни: історія потрібна
--       для розрахунку зарплати та аудиту
--     - не може редагувати записи працівників (це завдання HR)
--     - не має доступу до orders, order_items, customers,
--       customer_feedback, reservations
-- ================================================================


-- ----------------------------------------------------------------
-- 1. РОЛЬ (NOLOGIN: це лише контейнер прав, під нею ніхто не підключається)
-- ----------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'staff_role') THEN
        CREATE ROLE staff_role NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE;
    END IF;
END
$$;

COMMENT ON ROLE staff_role IS 'Керування змінами: читання довідників, INSERT/UPDATE змін. Без DELETE, без замовлень і клієнтів.';


-- ----------------------------------------------------------------
-- 2. КОРИСТУВАЧ ТА ЧЛЕНСТВО У РОЛІ
-- ----------------------------------------------------------------
-- Лише демонстраційний пароль. У реальних системах паролі не зберігають у Git.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'staff_user_1') THEN
        CREATE USER staff_user_1 WITH PASSWORD 'staff_password_2026'
            NOSUPERUSER NOCREATEDB NOCREATEROLE;
    END IF;
END
$$;

GRANT staff_role TO staff_user_1;


-- ----------------------------------------------------------------
-- 3. СКИДАННЯ ПРАВ (не покладаємося на значення за замовчуванням,
--    результат однаковий при кожному запуску)
-- ----------------------------------------------------------------
-- Забирає права staff_role на таблиці, колонки та послідовності.
-- Далі в розділі 4 видаємо рівно те, що потрібно.
REVOKE ALL ON ALL TABLES    IN SCHEMA public FROM staff_role;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM staff_role;


-- ----------------------------------------------------------------
-- 4. НАДАННЯ ПРАВ (принцип мінімальних привілеїв)
-- ----------------------------------------------------------------

-- Рівень схеми: USAGE обов'язковий, інакше будь-який доступ до таблиць
-- завершується помилкою "permission denied for schema public".
GRANT USAGE ON SCHEMA public TO staff_role;

-- Рівень таблиці: довідкові дані, потрібні для планування змін.
GRANT SELECT ON locations, menu_categories, menu_items TO staff_role;

-- Рівень колонки: для планування змін потрібні імена та посади колег,
-- але birth_date / phone / email / middle_name є персональними даними.
GRANT SELECT (staff_id, location_id, first_name, last_name, position, is_active)
    ON TABLE staff TO staff_role;

-- Рівень таблиці: планування змін - читання та створення змін.
GRANT SELECT, INSERT ON TABLE shift_schedules TO staff_role;

-- Рівень колонки: зміни можна редагувати (статус, фактичний час, перерви,
-- перепризначення), але НЕ первинний ключ shift_id: ідентифікатори мають
-- залишатися стабільними - це захищає цілісність даних.
GRANT UPDATE (location_id, staff_id, start_time, end_time,
              actual_start_time, actual_end_time, break_time_minutes, status)
    ON TABLE shift_schedules TO staff_role;

-- Рівень послідовності: для INSERT потрібен nextval() для bigserial
-- таблиці shift_schedules. Надається лише ця одна послідовність,
-- а не ALL SEQUENCES.
DO $$
BEGIN
    EXECUTE format('GRANT USAGE ON SEQUENCE %s TO staff_role',
                   pg_get_serial_sequence('public.shift_schedules', 'shift_id'));
END
$$;


-- ----------------------------------------------------------------
-- 5. ЯВНІ МЕЖІ ДОСТУПУ (REVOKE)
-- ----------------------------------------------------------------
-- REVOKE права, яке ніколи не надавалось, зараз нічого не змінює, проте
-- він документує межу доступу і захищає її, якщо хтось пізніше додасть
-- ширший GRANT або права за замовчуванням.

-- Зміни - це історія для зарплати та аудиту: скасовуємо через
-- status = 'CANCELLED', але ніколи не видаляємо і не очищаємо TRUNCATE.
REVOKE DELETE, TRUNCATE ON TABLE shift_schedules FROM staff_role;

-- Немає доступу до замовлень, грошових даних та даних клієнтів.
REVOKE ALL ON TABLE orders, order_items, customers, customer_feedback, reservations
    FROM staff_role;


-- ----------------------------------------------------------------
-- 6. АВТОМАТИЧНІ ТЕСТИ ПРАВ ДОСТУПУ (DO-блок)
-- ----------------------------------------------------------------
-- Кожен тест виконує один запит ВІД ІМЕНІ staff_user_1 (SET LOCAL ROLE)
-- у підтранзакції та порівнює фактичний результат з очікуваним:
--   DENIED  = PostgreSQL повернув "insufficient_privilege" (SQLSTATE 42501)
--   ALLOWED = перевірку прав пройдено. Запит може завершитися помилкою
--             пізніше через дані (наприклад, порушення зовнішнього ключа
--             в порожній базі, SQLSTATE класу 23) - для прав це все одно
--             успішний результат.
-- Кожен тест відкочується, тому тестових даних у базі не залишається.
-- Якщо хоча б один тест не збігся з очікуванням, блок викликає EXCEPTION,
-- тож неправильні права ніколи не залишаться непоміченими.
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
            ('staff_user_1', $q$INSERT INTO shift_schedules (location_id, staff_id, start_time, end_time)
                               VALUES (1, 1, now(), now() + interval '8 hours')$q$,
                'ALLOWED', 'персонал може планувати зміну (INSERT + послідовність)'),
            ('staff_user_1', $q$UPDATE shift_schedules SET status = 'COMPLETED', actual_end_time = now()
                               WHERE shift_id = -1$q$,
                'ALLOWED', 'персонал може оновлювати статус зміни та фактичний час'),
            ('staff_user_1', $q$UPDATE shift_schedules SET shift_id = shift_id WHERE shift_id = -1$q$,
                'DENIED',  'персонал не може змінювати первинний ключ shift_id'),
            ('staff_user_1', $q$DELETE FROM shift_schedules WHERE shift_id = -1$q$,
                'DENIED',  'персонал не може видаляти зміни (історія зберігається)'),
            ('staff_user_1', $q$TRUNCATE shift_schedules$q$,
                'DENIED',  'персонал не може виконувати TRUNCATE для змін'),
            ('staff_user_1', $q$SELECT first_name, last_name, position FROM staff$q$,
                'ALLOWED', 'персонал може читати імена та посади колег'),
            ('staff_user_1', $q$SELECT birth_date FROM staff$q$,
                'DENIED',  'персонал не може читати персональні дані колег'),
            ('staff_user_1', $q$UPDATE staff SET is_active = false WHERE staff_id = -1$q$,
                'DENIED',  'персонал не може редагувати записи staff (завдання HR)'),
            ('staff_user_1', $q$SELECT name, price FROM menu_items$q$,
                'ALLOWED', 'персонал може читати меню'),
            ('staff_user_1', $q$SELECT * FROM orders$q$,
                'DENIED',  'персонал не може читати замовлення'),
            ('staff_user_1', $q$SELECT * FROM customers$q$,
                'DENIED',  'персонал не може читати дані клієнтів'),
            ('staff_user_1', $q$UPDATE order_items SET quantity = 1 WHERE order_id = -1$q$,
                'DENIED',  'персонал не може змінювати позиції замовлень'),
            ('staff_user_1', $q$CREATE TABLE public.staff_hack_test (id int)$q$,
                'DENIED',  'персонал не може створювати таблиці в схемі public')
        ) AS x(usr, stmt, expected, descr)
    LOOP
        v_total   := v_total + 1;
        v_outcome := NULL;

        BEGIN
            EXECUTE format('SET LOCAL ROLE %I', t.usr);
            EXECUTE t.stmt;
            v_outcome := 'ALLOWED';
            -- Завжди відкочуємо тест (скасовує INSERT/UPDATE/DDL і зміну ролі).
            RAISE EXCEPTION 'відкат тесту' USING ERRCODE = 'RB001';
        EXCEPTION
            WHEN SQLSTATE 'RB001' THEN
                NULL;                                   -- запит виконано, v_outcome = ALLOWED
            WHEN insufficient_privilege THEN
                v_outcome := 'DENIED';
            WHEN OTHERS THEN
                IF SQLSTATE LIKE '23%' THEN             -- порушення цілісності = права були достатні
                    v_outcome := 'ALLOWED';
                ELSE
                    v_outcome := 'ПОМИЛКА: ' || SQLERRM;  -- наприклад, помилка в самому тесті
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
        RAISE EXCEPTION 'Не пройдено тестів прав: % - дивіться рядки [FAIL] вище', v_failed;
    END IF;
END
$$;


-- ----------------------------------------------------------------
-- 7. НЕОБОВ'ЯЗКОВО: ПЕРЕГЛЯД ПРАВ (виконується вручну)
-- ----------------------------------------------------------------
-- Права на рівні таблиць:
-- SELECT grantee, table_name, privilege_type
-- FROM information_schema.role_table_grants
-- WHERE grantee = 'staff_role'
-- ORDER BY table_name, privilege_type;

-- Права на рівні колонок (staff, shift_schedules):
-- SELECT grantee, table_name, column_name, privilege_type
-- FROM information_schema.column_privileges
-- WHERE grantee = 'staff_role' AND table_name IN ('staff', 'shift_schedules')
-- ORDER BY table_name, column_name, privilege_type;


-- ----------------------------------------------------------------
-- 8. НЕОБОВ'ЯЗКОВО: ОЧИЩЕННЯ (за замовчуванням закоментовано)
-- ----------------------------------------------------------------
-- DROP OWNED BY прибирає ВСІ права цих ролей у поточній базі даних
-- (права на таблиці, колонки, послідовності). Без нього DROP ROLE
-- завершується помилкою "cannot be dropped because some objects depend on it".
-- Порядок: DROP OWNED -> DROP USER -> DROP ROLE.

-- DROP OWNED BY staff_user_1, staff_role;
-- DROP USER IF EXISTS staff_user_1;
-- DROP ROLE IF EXISTS staff_role;
