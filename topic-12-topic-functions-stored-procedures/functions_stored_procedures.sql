-- ================================================================
-- FUNCTIONS & STORED PROCEDURES TEMPLATE (TOPIC 12)
-- ================================================================
-- WHAT SHOULD BE ADDED HERE:
--
-- FUNCTIONS (at least 3):
--   - Each function should encapsulate reusable logic or a
--     calculation relevant to your project domain.
--   - Use CREATE OR REPLACE FUNCTION ... RETURNS ...
--
-- STORED PROCEDURES — SELECT / INSERT (at least 2):
--   - Procedures that retrieve data or insert new records.
--   - Use CREATE OR REPLACE PROCEDURE ...
--
-- STORED PROCEDURES — UPDATE (at least 2):
--   - Procedures that modify existing records.
--
-- FOR EACH FUNCTION / PROCEDURE, ADD COMMENTS EXPLAINING:
--   - Purpose: what it does
--   - Parameters: name, type, meaning
--   - Expected behavior / return value
--
-- TEST CALLS:
--   - Include at least one example call per function/procedure
--     (SELECT my_function(...) or CALL my_procedure(...))
--
-- OPTIONAL:
--   - EXCEPTION blocks for error handling
--   - Transaction management with BEGIN / COMMIT / ROLLBACK
--
-- RECOMMENDED ORDER:
-- 1) Functions
-- 2) SELECT / INSERT procedures
-- 3) UPDATE procedures
-- 4) Test calls
--
-- IMPORTANT:
-- - All routines must execute in PostgreSQL without errors.
-- - Logic must be relevant to your project domain.
-- - Submit everything in this single SQL file.
-- ================================================================

-- Add your functions and procedures below this line

-- ================================================================
-- Lesson 12: Functions & Stored Procedures
-- Author: Fronts Vitaliy
-- ================================================================

-- ----------------------------------------------------------------
-- 1. FUNCTIONS
-- ----------------------------------------------------------------

-- Calculate total amount of an order
CREATE OR REPLACE FUNCTION calculate_order_total(p_order_id BIGINT)
RETURNS numeric(10,2) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_total numeric(10,2);
BEGIN
    SELECT COALESCE(SUM(quantity * item_price), 0)
    INTO v_total
    FROM order_items
    WHERE order_id = p_order_id;
    
    RETURN v_total;
END;
$$;


-- Check if an ingredient stock is critical
CREATE OR REPLACE FUNCTION is_stock_critical(p_location_id BIGINT, p_ingredient_id BIGINT)
RETURNS boolean 
LANGUAGE plpgsql
AS $$
DECLARE
    v_is_critical boolean;
BEGIN
    SELECT (current_stock <= min_stock_level)
    INTO v_is_critical
    FROM location_inventory
    WHERE location_id = p_location_id 
      AND ingredient_id = p_ingredient_id;
      
    RETURN COALESCE(v_is_critical, false);
END;
$$;


-- Format customer full name
CREATE OR REPLACE FUNCTION get_customer_full_name(p_customer_id BIGINT)
RETURNS varchar 
LANGUAGE plpgsql
AS $$
DECLARE
    v_full_name varchar;
BEGIN
    SELECT TRIM(first_name || ' ' || COALESCE(last_name, ''))
    INTO v_full_name
    FROM customers
    WHERE customer_id = p_customer_id;
    
    RETURN v_full_name;
END;
$$;


-- ----------------------------------------------------------------
-- 2. STORED PROCEDURES
-- ----------------------------------------------------------------

-- Register a new customer with error handling
CREATE OR REPLACE PROCEDURE register_customer(
    p_first_name varchar(80),
    p_last_name varchar(80),
    p_phone varchar(30),
    p_email varchar(150)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO customers (first_name, last_name, phone, email)
    VALUES (p_first_name, p_last_name, p_phone, p_email);
    
    RAISE NOTICE 'Customer % % registered successfully.', p_first_name, p_last_name;
EXCEPTION 
    WHEN unique_violation THEN
        RAISE NOTICE 'Error: Email % is already registered in the system.', p_email;
END;
$$;


-- Add a new location
CREATE OR REPLACE PROCEDURE add_location(
    p_name varchar(100),
    p_address varchar(255)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO locations (name, address, is_active)
    VALUES (p_name, p_address, true);
    
    RAISE NOTICE 'Location "%" successfully added.', p_name;
END;
$$;


-- ----------------------------------------------------------------
-- 3. STORED PROCEDURES
-- ----------------------------------------------------------------

-- Update order status
CREATE OR REPLACE PROCEDURE update_order_status(
    p_order_id BIGINT,
    p_new_status order_status
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE orders
    SET status = p_new_status
    WHERE order_id = p_order_id;
    
    IF NOT FOUND THEN
        RAISE NOTICE 'Error: Order ID % not found.', p_order_id;
    ELSE
        RAISE NOTICE 'Order ID % status successfully updated to %.', p_order_id, p_new_status;
    END IF;
END;
$$;


-- Receive inventory
CREATE OR REPLACE PROCEDURE receive_inventory(
    p_location_id BIGINT,
    p_ingredient_id BIGINT,
    p_quantity_added numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_quantity_added <= 0 THEN
        RAISE EXCEPTION 'Quantity added must be greater than 0. Provided: %', p_quantity_added;
    END IF;

    UPDATE location_inventory
    SET current_stock = current_stock + p_quantity_added
    WHERE location_id = p_location_id AND ingredient_id = p_ingredient_id;
    
    IF NOT FOUND THEN
        RAISE NOTICE 'Error: Inventory record not found for Location % and Ingredient %.', p_location_id, p_ingredient_id;
    ELSE
        RAISE NOTICE 'Successfully added % units to stock.', p_quantity_added;
    END IF;
END;
$$;


-- ----------------------------------------------------------------
-- 4. TESTING BLOCK
-- ----------------------------------------------------------------

DO $$ 
BEGIN
    RAISE NOTICE '================ TESTING STARTED ================';

    -- 1. Test Functions
    RAISE NOTICE '--- Testing Functions ---';
    RAISE NOTICE 'Order 1 total amount: %', calculate_order_total(1);
    RAISE NOTICE 'Is stock critical (Loc 1, Ing 1)? %', is_stock_critical(1, 1);
    RAISE NOTICE 'Customer 1 full name: %', get_customer_full_name(1);
    
    -- 2. Test INSERT
    RAISE NOTICE '--- Testing Procedures (INSERT) ---';
    -- Valid insert
    CALL register_customer('Ivan', 'Franko', '+380991112233', 'ivan.test@example.com');
    -- Duplicate insert
    CALL register_customer('Ivan', 'Franko', '+380991112233', 'ivan.test@example.com');
    
    CALL add_location('Lviv Test Hub', 'м. Львів, вул. Тестова, 99');
    
    -- 3. Test UPDATE
    RAISE NOTICE '--- Testing Procedures (UPDATE) ---';
    -- Validating safe update
    CALL update_order_status(1, 'COMPLETED');
    
    -- Validating update with transaction
    CALL receive_inventory(1, 1, 10.500);
    
    RAISE NOTICE '================ TESTING FINISHED ================';
END $$;
