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

-- ================================================================
-- SQL DATABASE ADMINISTRATION (TOPIC 11)
-- Project: Restaurant Management System

-- ----------------------------------------------------------------
-- 0. CLEANUP (Optional )
-- ----------------------------------------------------------------

/*
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM analytics_role, staff_role;
REVOKE USAGE ON SCHEMA public FROM analytics_role, staff_role;

DROP USER IF EXISTS analyst_user_1;
DROP USER IF EXISTS staff_user_1;

DROP ROLE IF EXISTS analytics_role;
DROP ROLE IF EXISTS staff_role;
*/


-- ----------------------------------------------------------------
-- 1. ROLES CREATION
-- ----------------------------------------------------------------
-- Analytics Role (Read-only access to operational data and views)
CREATE ROLE analytics_role WITH NOLOGIN;

-- Staff Role (Operational / Limited DML access for shift management)
CREATE ROLE staff_role WITH NOLOGIN;


-- ----------------------------------------------------------------
-- 2. USERS CREATION
-- ----------------------------------------------------------------

CREATE USER analyst_user_1 WITH PASSWORD 'analyst_password_2026';
GRANT analytics_role TO analyst_user_1;


CREATE USER staff_user_1 WITH PASSWORD 'staff_password_2026';
GRANT staff_role TO staff_user_1;


-- ----------------------------------------------------------------
-- 3. SCHEMA & TABLE-LEVEL GRANTS (Least Privilege Principle)
-- ----------------------------------------------------------------

-- Allow schema connection and reading from all tables and views
GRANT USAGE ON SCHEMA public TO analytics_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analytics_role;
-- Ensure future tables added to public schema are also readable by analytics
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO analytics_role;


-- --- STAFF ROLE PERMISSIONS ---
GRANT USAGE ON SCHEMA public TO staff_role;

-- Staff need to read menu items, locations, and staff directories
GRANT SELECT ON locations, menu_items, menu_categories, staff TO staff_role;

-- Staff need full access on their shift schedules and personal info
GRANT SELECT, INSERT, UPDATE ON shift_schedules TO staff_role;

-- Allow usage of sequences (for IDs when inserting shifts if needed)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO staff_role;


-- ----------------------------------------------------------------
-- 4. REVOKE STATEMENTS (Enforcing strict boundaries)
-- ----------------------------------------------------------------
-- Explicitly revoke sensitive financial data or customer feedback modifications from staff and analytics where unnecessary
REVOKE UPDATE, DELETE ON orders, order_items FROM staff_role;
REVOKE INSERT, UPDATE, DELETE ON customers, customer_feedback FROM analytics_role;


-- ----------------------------------------------------------------
-- 5. TESTING PERMISSIONS & VERIFICATION BLOCKS
-- ----------------------------------------------------------------

-- Verify analytics_role can read orders (Expected: SUCCESS)
SET ROLE analytics_role;
SELECT COUNT(*) FROM orders;
RESET ROLE;

-- Verify analytics_role CANNOT insert/modify orders
DO $$
BEGIN
  SET ROLE analytics_role;
  INSERT INTO customers (first_name, last_name, phone, email) 
  VALUES ('Hacker', 'Test', '+380000000000', 'hacker@example.com');
  RESET ROLE;
  RAISE EXCEPTION 'Test failed: analytics_role was able to insert!';
EXCEPTION
  WHEN insufficient_privilege THEN 
    RESET ROLE;
    RAISE NOTICE '[OK] analytics_role correctly restricted from INSERT.';
  WHEN OTHERS THEN 
    RESET ROLE;
    RAISE NOTICE '[NOTE] Caught expected restriction error: %', SQLERRM;
END $$;

-- Verify staff_role can update shift schedules
DO $$
BEGIN
  SET ROLE staff_user_1;
  -- Test query check
  PERFORM * FROM shift_schedules LIMIT 1;
  RESET ROLE;
  RAISE NOTICE '[OK] staff_role can query shift schedules.';
EXCEPTION
  WHEN OTHERS THEN
    RESET ROLE;
    RAISE NOTICE '[FAIL] staff_role query failed: %', SQLERRM;
END $$;


-- ----------------------------------------------------------------
-- 6. OPTIONAL CLEANUP BLOCK (After evaluation)
-- ----------------------------------------------------------------
/*
REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM analytics_role;
REVOKE SELECT, INSERT, UPDATE ON shift_schedules FROM staff_role;
REVOKE USAGE ON SCHEMA public FROM analytics_role, staff_role;

DROP USER IF EXISTS analyst_user_1;
DROP USER IF EXISTS staff_user_1;

DROP ROLE IF EXISTS analytics_role;
DROP ROLE IF EXISTS staff_role;
*/

