# TicketFlow — Backend

Spring Boot 4 (Java 21) API for TicketFlow, backed by **Neon Postgres** via Flyway migrations.

## Prerequisites

- Java 21 (`java -version`)
- Node.js 20+ (only for the Neon CLI)
- Access to Neon organization `org-super-butterfly-56805018` (ask a teammate for an invite, role **Member**)

## First-time setup

```bash
# 1. Install the Neon CLI and sign in
npm i -g neon@latest
neon login

# 2. Link this folder to the project (pick the org, then calm-dew-08692389)
neon link

# 3. Pull the shared development branch's env vars into the gitignored .env.local
neon env pull --branch development

# 4. Convert Neon's URL into Spring Boot's DB_URL / DB_USERNAME / DB_PASSWORD
#    Windows:
powershell -File scripts/sync-neon-env.ps1
#    macOS / Linux / Git Bash:
./scripts/sync-neon-env.sh

# 5. Run the API
cd backend/ticketflow-backend
./mvnw spring-boot:run        # Windows: .\mvnw.cmd spring-boot:run
```

The API starts on `http://localhost:8080`. Flyway applies any pending migrations
on startup, so a fresh checkout against a fresh branch self-provisions the schema.

## How configuration is loaded

`src/main/resources/application.properties` imports the repo-root env files:

```properties
spring.config.import=optional:file:../../.env[.properties],optional:file:../../.env.local[.properties]
```

Those paths are relative to this module's working directory (`backend/ticketflow-backend`),
which is what Maven and standard IDE run configurations use. `.env` / `.env.local`
are gitignored — never commit real credentials. `.env.example` documents the keys.

## Database

| Item | Value |
| --- | --- |
| Project | `calm-dew-08692389` (`neon.com` console) |
| Shared branch | `development` (`br-hidden-haze-aon0g0i4`, endpoint `ep-spring-butterfly-aopcm7lw`) |
| Deploy branch | `production` (do not point local runs at it) |
| Database / role | `neondb` / `neondb_owner` |

Pooling is currently disabled on the endpoints, so the app uses the direct host
(`DATABASE_URL_UNPOOLED`). Enable the pooler in the Neon console and use
`./scripts/sync-neon-env.sh --pooled` if connection counts become a problem.

## Migrations

SQL files live in `src/main/resources/db/migration` and follow the stages in
`database-schemas.md`:

| Version | Contents |
| --- | --- |
| V1 | users, organizer_profiles |
| V2 | cities, cinemas, facilities, screens, seats |
| V3 | movies, genres, movie_genres, movie_cast |
| V4 | shows, show_seats |
| V5 | bookings, booking_seats, tickets |
| V6 | payments |
| V7 | refunds, refund_items |
| V8 | customer_wallets, credit_ledger |
| V9 | refresh_tokens, password_reset_tokens, idempotency_keys, notifications |

Rules for the shared branch:

1. Never edit a migration that has already been applied — add a new `V<n>__*.sql` instead.
2. Coordinate version numbers before merging (two people must not both add `V10`).
3. Keep `spring.jpa.hibernate.ddl-auto=validate`; Flyway owns the schema.

## Tests

```bash
./mvnw test
```

`TicketflowBackendApplicationTests` is a full `@SpringBootTest`, so it connects to
whatever branch `.env.local` points at (currently `development`). A H2/Testcontainers
profile is not set up yet.

## Troubleshooting

- **`Port 8080 was already in use`** — stop the other process or run with
  `./mvnw spring-boot:run -Dspring-boot.run.arguments=--server.port=8081`.
- **`UnknownHostException` for a Neon host** — the endpoint may still be waking up;
  retry. If it persists, check `neon env pull` selected the right branch.
- **`Could not resolve placeholder 'DB_URL'`** — `.env.local` is missing or the sync
  script was not run; repeat steps 3–4.
- **Password rotated** — re-run `neon env pull --branch development` and the sync script.
