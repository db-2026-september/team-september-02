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
