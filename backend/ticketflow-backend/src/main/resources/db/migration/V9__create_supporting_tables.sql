-- V9: authentication tokens, idempotency keys and notifications.

CREATE TABLE refresh_tokens (
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id    BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens (user_id);

CREATE TABLE password_reset_tokens (
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id    BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    used_at    TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_password_reset_tokens_user_id ON password_reset_tokens (user_id);

CREATE TABLE idempotency_keys (
    id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    key           VARCHAR(100) NOT NULL UNIQUE,
    customer_id   BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    request_hash  VARCHAR(255) NOT NULL,
    response_body JSONB,
    expires_at    TIMESTAMPTZ NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_idempotency_keys_expires_at ON idempotency_keys (expires_at);

CREATE TABLE notifications (
    id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id           BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    title             VARCHAR(150) NOT NULL,
    message           TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    reference_type    VARCHAR(30),
    reference_id      BIGINT,
    is_read           BOOLEAN NOT NULL DEFAULT FALSE,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_read ON notifications (user_id, is_read);
