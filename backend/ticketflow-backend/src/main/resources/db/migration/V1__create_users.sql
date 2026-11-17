-- V1: users and organizer profiles.

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE users (
    id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name      VARCHAR(100) NOT NULL,
    email          VARCHAR(255) NOT NULL,
    password_hash  VARCHAR(255) NOT NULL,
    phone_number   VARCHAR(20),
    role           VARCHAR(20)  NOT NULL,
    status         VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
    email_verified BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT ck_users_role CHECK (role IN ('CUSTOMER', 'ORGANIZER')),
    CONSTRAINT ck_users_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'BLOCKED'))
);

-- Email uniqueness is case-insensitive.
CREATE UNIQUE INDEX ux_users_email_lower ON users (LOWER(email));

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE organizer_profiles (
    id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id        BIGINT NOT NULL UNIQUE REFERENCES users (id) ON DELETE CASCADE,
    business_name  VARCHAR(150),
    contact_person VARCHAR(100),
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_organizer_profiles_updated_at
    BEFORE UPDATE ON organizer_profiles
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
