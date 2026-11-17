-- V2: cities, cinemas, facilities, screens and physical seats.

CREATE TABLE cities (
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city_name  VARCHAR(100) NOT NULL,
    state_name VARCHAR(100) NOT NULL,
    country    VARCHAR(100) NOT NULL,
    is_active  BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE cinemas (
    id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    owner_id       BIGINT NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    city_id        BIGINT NOT NULL REFERENCES cities (id) ON DELETE RESTRICT,
    cinema_name    VARCHAR(150) NOT NULL,
    address        TEXT NOT NULL,
    postal_code    VARCHAR(15),
    contact_number VARCHAR(20),
    status         VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_cinemas_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED'))
);

CREATE INDEX idx_cinemas_owner_id ON cinemas (owner_id);
CREATE INDEX idx_cinemas_city_id ON cinemas (city_id);

CREATE TRIGGER trg_cinemas_updated_at
    BEFORE UPDATE ON cinemas
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE cinema_facilities (
    id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    facility_name VARCHAR(100) NOT NULL UNIQUE,
    description   TEXT
);

CREATE TABLE cinema_facility_map (
    cinema_id   BIGINT NOT NULL REFERENCES cinemas (id) ON DELETE CASCADE,
    facility_id BIGINT NOT NULL REFERENCES cinema_facilities (id) ON DELETE CASCADE,
    PRIMARY KEY (cinema_id, facility_id)
);

CREATE TABLE screens (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cinema_id   BIGINT NOT NULL REFERENCES cinemas (id) ON DELETE CASCADE,
    screen_name VARCHAR(50) NOT NULL,
    screen_type VARCHAR(30),
    total_seats INTEGER NOT NULL,
    status      VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ux_screens_cinema_name UNIQUE (cinema_id, screen_name),
    CONSTRAINT ck_screens_status CHECK (status IN ('ACTIVE', 'INACTIVE')),
    CONSTRAINT ck_screens_total_seats CHECK (total_seats > 0)
);

CREATE TABLE seats (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    screen_id   BIGINT NOT NULL REFERENCES screens (id) ON DELETE CASCADE,
    row_label   VARCHAR(10) NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    seat_type   VARCHAR(30) NOT NULL,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ux_seats_screen_position UNIQUE (screen_id, row_label, seat_number),
    CONSTRAINT ck_seats_type CHECK (seat_type IN ('REGULAR', 'PREMIUM', 'RECLINER'))
);

CREATE INDEX idx_seats_screen_id ON seats (screen_id);
