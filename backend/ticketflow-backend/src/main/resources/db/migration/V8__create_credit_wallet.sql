-- V8: in-app credit wallet (projection) and immutable ledger (source of truth).

CREATE TABLE customer_wallets (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL UNIQUE REFERENCES users (id) ON DELETE CASCADE,
    balance     BIGINT NOT NULL DEFAULT 0,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_customer_wallets_balance CHECK (balance >= 0)
);

CREATE TRIGGER trg_customer_wallets_updated_at
    BEFORE UPDATE ON customer_wallets
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE credit_ledger (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id      BIGINT NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    type             VARCHAR(30) NOT NULL,
    amount           BIGINT NOT NULL,
    balance_after    BIGINT NOT NULL,
    reference_type   VARCHAR(30),
    reference_id     BIGINT,
    remaining_amount BIGINT,
    expires_at       TIMESTAMPTZ,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_credit_ledger_type CHECK (
        type IN ('REFUND', 'COUPON', 'PURCHASE_USE', 'EXPIRY', 'ADMIN_ADJUSTMENT', 'REVERSAL')
    ),
    CONSTRAINT ck_credit_ledger_balance CHECK (balance_after >= 0),
    CONSTRAINT ck_credit_ledger_remaining CHECK (remaining_amount IS NULL OR remaining_amount >= 0)
);

CREATE INDEX idx_credit_ledger_customer_created ON credit_ledger (customer_id, created_at DESC);
CREATE INDEX idx_credit_ledger_unspent
    ON credit_ledger (customer_id, expires_at)
    WHERE remaining_amount > 0;
