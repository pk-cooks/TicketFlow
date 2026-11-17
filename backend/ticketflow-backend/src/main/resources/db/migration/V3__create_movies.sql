-- V3: movies, genres, movie-genre links and cast.

CREATE TABLE movies (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cinema_id        BIGINT NOT NULL REFERENCES cinemas (id) ON DELETE CASCADE,
    title            VARCHAR(200) NOT NULL,
    description      TEXT,
    language         VARCHAR(50) NOT NULL,
    duration_minutes INTEGER NOT NULL,
    certification    VARCHAR(20),
    release_date     DATE,
    poster_url       TEXT,
    trailer_url      TEXT,
    status           VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_movies_status CHECK (status IN ('DRAFT', 'PUBLISHED', 'NOW_SHOWING', 'COMING_SOON', 'INACTIVE')),
    CONSTRAINT ck_movies_duration CHECK (duration_minutes > 0)
);

CREATE INDEX idx_movies_cinema_id ON movies (cinema_id);

CREATE TRIGGER trg_movies_updated_at
    BEFORE UPDATE ON movies
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE genres (
    id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    genre_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE movie_genres (
    movie_id BIGINT NOT NULL REFERENCES movies (id) ON DELETE CASCADE,
    genre_id BIGINT NOT NULL REFERENCES genres (id) ON DELETE CASCADE,
    PRIMARY KEY (movie_id, genre_id)
);

CREATE TABLE movie_cast (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    movie_id    BIGINT NOT NULL REFERENCES movies (id) ON DELETE CASCADE,
    person_name VARCHAR(150) NOT NULL,
    role_type   VARCHAR(20) NOT NULL,
    CONSTRAINT ck_movie_cast_role_type CHECK (role_type IN ('ACTOR', 'DIRECTOR'))
);

CREATE INDEX idx_movie_cast_movie_id ON movie_cast (movie_id);
