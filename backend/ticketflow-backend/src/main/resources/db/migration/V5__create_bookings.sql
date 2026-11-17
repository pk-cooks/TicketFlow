-- V5: bookings, booked seats and tickets.

CREATE TABLE bookings (
    id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_reference VARCHAR(50) NOT NULL UNIQUE,
    customer_id       BIGINT NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    show_id           BIGINT NOT NULL REFERENCES shows (id) ON DELETE RESTRICT,
    ticket_amount     NUMERIC(12, 2) NOT NULL,
    convenience_fee   NUMERIC(12, 2) NOT NULL DEFAULT 0,
    total_amount      NUMERIC(12, 2) NOT NULL,
    currency          VARCHAR(3) NOT NULL DEFAULT 'INR',
    status            VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    expires_at        TIMESTAMPTZ,
    confirmed_at      TIMESTAMPTZ,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_bookings_status CHECK (status IN ('PENDING', 'CONFIRMED', 'CANCELLED', 'EXPIRED')),
    CONSTRAINT ck_bookings_amounts CHECK (
        ticket_amount >= 0 AND convenience_fee >= 0 AND total_amount >= 0
    )
);

CREATE INDEX idx_bookings_customer_created ON bookings (customer_id, created_at DESC);
CREATE INDEX idx_bookings_show_id ON bookings (show_id);

CREATE TRIGGER trg_bookings_updated_at
    BEFORE UPDATE ON bookings
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE booking_seats (
    id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_id    BIGINT NOT NULL REFERENCES bookings (id) ON DELETE CASCADE,
    show_seat_id  BIGINT NOT NULL REFERENCES show_seats (id) ON DELETE RESTRICT,
    booked_price  NUMERIC(12, 2) NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ux_booking_seats_booking_show_seat UNIQUE (booking_id, show_seat_id),
    CONSTRAINT ck_booking_seats_price CHECK (booked_price >= 0)
);

CREATE INDEX idx_booking_seats_booking_id ON booking_seats (booking_id);

-- One ticket per confirmed booking, one shared QR reference for all seats.
CREATE TABLE tickets (
    id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_id        BIGINT NOT NULL UNIQUE REFERENCES bookings (id) ON DELETE RESTRICT,
    qr_code_reference VARCHAR(255) NOT NULL UNIQUE,
    status            VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    generated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_tickets_status CHECK (status IN ('ACTIVE', 'CANCELLED'))
);
