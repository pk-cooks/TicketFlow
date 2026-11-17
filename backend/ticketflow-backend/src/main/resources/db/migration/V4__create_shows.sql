-- V4: shows and per-show seat availability/pricing.

-- Needed for the exclusion constraint that prevents overlapping shows on a screen.
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE shows (
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    movie_id   BIGINT NOT NULL REFERENCES movies (id) ON DELETE RESTRICT,
    screen_id  BIGINT NOT NULL REFERENCES screens (id) ON DELETE RESTRICT,
    start_time TIMESTAMPTZ NOT NULL,
    end_time   TIMESTAMPTZ NOT NULL,
    format     VARCHAR(20),
    language   VARCHAR(50) NOT NULL,
    status     VARCHAR(20) NOT NULL DEFAULT 'SCHEDULED',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_shows_time_range CHECK (end_time > start_time),
    CONSTRAINT ck_shows_status CHECK (status IN ('SCHEDULED', 'AVAILABLE', 'CANCELLED', 'COMPLETED')),
    CONSTRAINT ex_shows_no_overlap EXCLUDE USING gist (
        screen_id WITH =,
        tstzrange(start_time, end_time) WITH &&
    ) WHERE (status <> 'CANCELLED')
);

CREATE INDEX idx_shows_movie_start_time ON shows (movie_id, start_time);
CREATE INDEX idx_shows_screen_start_time ON shows (screen_id, start_time);

CREATE TRIGGER trg_shows_updated_at
    BEFORE UPDATE ON shows
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE show_seats (
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    show_id         BIGINT NOT NULL REFERENCES shows (id) ON DELETE CASCADE,
    seat_id         BIGINT NOT NULL REFERENCES seats (id) ON DELETE CASCADE,
    price           NUMERIC(12, 2) NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',
    hold_expires_at TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ux_show_seats_show_seat UNIQUE (show_id, seat_id),
    CONSTRAINT ck_show_seats_price CHECK (price >= 0),
    CONSTRAINT ck_show_seats_status CHECK (status IN ('AVAILABLE', 'RESERVED', 'BOOKED', 'BLOCKED'))
);

CREATE INDEX idx_show_seats_show_status ON show_seats (show_id, status);

CREATE TRIGGER trg_show_seats_updated_at
    BEFORE UPDATE ON show_seats
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
