-- V7: refunds and per-seat refund calculation.

CREATE TABLE refunds (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_id       BIGINT NOT NULL REFERENCES bookings (id) ON DELETE RESTRICT,
    payment_id       BIGINT REFERENCES payments (id) ON DELETE SET NULL,
    amount           NUMERIC(12, 2) NOT NULL,
    reason           TEXT NOT NULL,
    status           VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    refund_reference VARCHAR(150),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    processed_at     TIMESTAMPTZ,
    CONSTRAINT ck_refunds_amount CHECK (amount >= 0),
    CONSTRAINT ck_refunds_status CHECK (status IN ('PENDING', 'PROCESSING', 'SUCCESS', 'FAILED'))
);

CREATE INDEX idx_refunds_booking_id ON refunds (booking_id);
CREATE INDEX idx_refunds_payment_id ON refunds (payment_id);

CREATE TABLE refund_items (
    id                  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    refund_id           BIGINT NOT NULL REFERENCES refunds (id) ON DELETE CASCADE,
    booking_seat_id     BIGINT NOT NULL REFERENCES booking_seats (id) ON DELETE RESTRICT,
    price_paid          NUMERIC(12, 2) NOT NULL,
    cancellation_charge NUMERIC(12, 2) NOT NULL,
    refund_amount       NUMERIC(12, 2) NOT NULL,
    CONSTRAINT ux_refund_items_refund_seat UNIQUE (refund_id, booking_seat_id),
    CONSTRAINT ck_refund_items_amounts CHECK (
        price_paid >= 0 AND cancellation_charge >= 0 AND refund_amount >= 0
    )
);
