#!/usr/bin/env bash
#
# Derives Spring Boot datasource variables from Neon's connection URL.
#
# `neon env pull` writes DATABASE_URL and DATABASE_URL_UNPOOLED into the
# gitignored .env.local (or .env) file. Spring Boot needs a JDBC URL plus
# credentials in separate properties, so this script converts the direct
# (non-pooled) URL into DB_URL, DB_USERNAME and DB_PASSWORD and updates the
# same file. Run it again whenever the Neon password or branch changes.
#
# Usage:
#   ./scripts/sync-neon-env.sh            # prefer DATABASE_URL_UNPOOLED
#   ./scripts/sync-neon-env.sh --pooled   # prefer DATABASE_URL
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

ENV_FILE=""
for candidate in "$ROOT_DIR/.env.local" "$ROOT_DIR/.env"; do
    if [ -f "$candidate" ]; then
        ENV_FILE="$candidate"
        break
    fi
done

if [ -z "$ENV_FILE" ]; then
    echo "No .env.local or .env found in $ROOT_DIR. Run 'neon env pull' first." >&2
    exit 1
fi

USE_POOLED=0
if [ "${1:-}" = "--pooled" ]; then
    USE_POOLED=1
fi

get_value() {
    local name="$1"
    local line
    line="$(grep -m1 "^${name}=" "$ENV_FILE" || true)"
    [ -z "$line" ] && return 0

    local value="${line#*=}"
    value="${value%$'\r'}"
    if [ "${#value}" -ge 2 ]; then
        case "$value" in
            \"*\") value="${value#\"}"; value="${value%\"}" ;;
            \'*\') value="${value#\'}"; value="${value%\'}" ;;
        esac
    fi
    printf '%s' "$value"
}

SOURCE_KEY="DATABASE_URL_UNPOOLED"
if [ "$USE_POOLED" -eq 1 ]; then
    SOURCE_KEY="DATABASE_URL"
fi

RAW_URL="$(get_value "$SOURCE_KEY")"
if [ -z "$RAW_URL" ]; then
    SOURCE_KEY="DATABASE_URL"
    RAW_URL="$(get_value "$SOURCE_KEY")"
fi
if [ -z "$RAW_URL" ]; then
    echo "No DATABASE_URL(_UNPOOLED) found in $ENV_FILE." >&2
    exit 1
fi

urldecode() {
    local value="${1//%/\\x}"
    printf '%b' "$value"
}

remainder="${RAW_URL#*://}"
if [ "$remainder" = "$RAW_URL" ]; then
    echo "DATABASE_URL must start with postgresql://" >&2
    exit 1
fi

userinfo="${remainder%%@*}"
hostpart="${remainder#*@}"

DB_USERNAME="$(urldecode "${userinfo%%:*}")"
DB_PASSWORD="$(urldecode "${userinfo#*:}")"

query=""
case "$hostpart" in
    *\?*) query="?${hostpart#*\?}"; hostpart="${hostpart%%\?*}" ;;
esac

host="${hostpart%%/*}"
pathpart="/${hostpart#*/}"
if [ "$pathpart" = "/$hostpart" ]; then
    pathpart="/neondb"
fi

if [ -z "$DB_USERNAME" ] || [ -z "$DB_PASSWORD" ]; then
    echo "DATABASE_URL is missing credentials (user:password@host)." >&2
    exit 1
fi

DB_URL="jdbc:postgresql://${host}${pathpart}${query}"

tmp_file="$(mktemp)"
grep -v -E '^(DB_URL|DB_USERNAME|DB_PASSWORD)=' "$ENV_FILE" > "$tmp_file" || true
{
    printf 'DB_URL=%s\n' "$DB_URL"
    printf 'DB_USERNAME=%s\n' "$DB_USERNAME"
    printf 'DB_PASSWORD=%s\n' "$DB_PASSWORD"
} >> "$tmp_file"
mv "$tmp_file" "$ENV_FILE"

echo "Wrote DB_URL, DB_USERNAME and DB_PASSWORD to $ENV_FILE (source: $SOURCE_KEY)"
