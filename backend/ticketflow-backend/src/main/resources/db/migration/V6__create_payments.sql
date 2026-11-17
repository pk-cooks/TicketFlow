-- V6: payment attempts and their outcomes.

CREATE TABLE payments (
    id                    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_id            BIGINT NOT NULL REFERENCES bookings (id) ON DELETE RESTRICT,
    amount                NUMERIC(12, 2) NOT NULL,
    currency              VARCHAR(3) NOT NULL,
    payment_method        VARCHAR(30) NOT NULL,
    payment_provider      VARCHAR(50),
    transaction_reference VARCHAR(150),
    idempotency_key       VARCHAR(100),
    status                VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    failure_reason        TEXT,
    paid_at               TIMESTAMPTZ,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_payments_amount CHECK (amount >= 0),
    CONSTRAINT ck_payments_method CHECK (payment_method IN ('UPI', 'CARD', 'NET_BANKING', 'CREDITS')),
    CONSTRAINT ck_payments_status CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED'))
);

CREATE INDEX idx_payments_booking_id ON payments (booking_id);
CREATE UNIQUE INDEX ux_payments_idempotency_key
    ON payments (idempotency_key)
    WHERE idempotency_key IS NOT NULL;

CREATE TRIGGER trg_payments_updated_at
    BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
