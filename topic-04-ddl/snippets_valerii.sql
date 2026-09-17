-- [Valerii] - staff management and shift scheduling tables

CREATE TABLE staff_mvp(
    staff_id bigserial PRIMARY KEY,
    location_id bigint NOT NULL REFERENCES locations_mvp(location_id),
    first_name varchar(80) NOT NULL,
    last_name varchar(80) NOT NULL,
    middle_name varchar(80),
    birth_date date NOT NULL,
    position varchar(30) NOT NULL,
    phone varchar(30) NOT NULL UNIQUE,
    email varchar(150) NOT NULL UNIQUE,
    is_active boolean DEFAULT TRUE
);

CREATE INDEX idx_staff_location ON staff_mvp(location_id);
CREATE INDEX idx_staff_name_birth ON staff_mvp(last_name, first_name, birth_date);

CREATE TYPE shift_status AS ENUM ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'NO_SHOW', 'CANCELLED');

CREATE TABLE shift_schedules_final(
    shift_id bigserial PRIMARY KEY,
    location_id bigint NOT NULL REFERENCES locations_mvp(location_id),
    staff_id bigint NOT NULL REFERENCES staff_mvp(staff_id),
    start_time timestamptz NOT NULL,
    end_time timestamptz NOT NULL,
    actual_start_time timestamptz,
    actual_end_time timestamptz,
    break_time_minutes smallint DEFAULT 0 CHECK (break_time_minutes >= 0),
    status shift_status NOT NULL DEFAULT 'SCHEDULED',

    CONSTRAINT chk_shift_time 
    CHECK (end_time > start_time),

    CONSTRAINT chk_actual_time_consistency
    CHECK ((actual_end_time IS NULL OR actual_start_time IS NOT NULL)
    AND (actual_end_time > actual_start_time) ),

    CONSTRAINT uq_shift_staff_slot
    UNIQUE (staff_id, start_time)
);

CREATE INDEX idx_shift_staff ON shift_schedules_final(staff_id);
CREATE INDEX idx_shift_location ON shift_schedules_final(location_id);
CREATE INDEX idx_shift_date ON shift_schedules_final((start_time::date));
CREATE INDEX idx_shift_location_date ON shift_schedules_final(location_id, (start_time::date));
