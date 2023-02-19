
/* PostgreSQL v 12.9 */
CREATE SCHEMA IF NOT EXISTS staging;

-- Складываем все, что приходит в моменте:
DROP TABLE IF EXISTS        staging.random_cannabis CASCADE;
CREATE TABLE IF NOT EXISTS  staging.random_cannabis (
    id       INTEGER NOT NULL,
    bid      UUID    NOT NULL,
    data     JSONB,
    lru_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS staging_random_cannabis_bid      ON staging.random_cannabis (bid);
CREATE INDEX IF NOT EXISTS staging_random_cannabis_lru_date ON staging.random_cannabis (lru_date);

-- Для того, чтобы ложить данные в стриме:
DROP TABLE IF EXISTS       staging.random_cannabis_snapshot CASCADE;
CREATE TABLE IF NOT EXISTS staging.random_cannabis_snapshot (
    id       INTEGER NOT NULL,
    bid      UUID    NOT NULL,
    data     JSONB,
    lru_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS staging_random_cannabis_snapshot_bid      ON staging.random_cannabis_snapshot (bid);
CREATE INDEX IF NOT EXISTS staging_random_cannabis_snapshot_lru_date ON staging.random_cannabis_snapshot (lru_date);

-- Чтобы записывать те, которые уже были обработаны:
DROP TABLE IF EXISTS       staging.random_cannabis_processed CASCADE;
CREATE TABLE IF NOT EXISTS staging.random_cannabis_processed (
    id              INTEGER NOT NULL,
    bid             UUID    NOT NULL,
    data            JSONB,
    lru_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processing_date TIMESTAMP NOT NULL
);
CREATE INDEX IF NOT EXISTS staging_random_cannabis_processed_bid      ON staging.random_cannabis_processed (bid);
CREATE INDEX IF NOT EXISTS staging_random_cannabis_processed_lru_date ON staging.random_cannabis_processed (lru_date);

