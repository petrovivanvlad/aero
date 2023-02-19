
/* PostgreSQL v 12.9 */
CREATE SCHEMA IF NOT EXISTS warehouse;

DROP TABLE IF EXISTS        warehouse.random_cannabis CASCADE;
CREATE TABLE IF NOT EXISTS  warehouse.random_cannabis (
    random_cannabis_id                       INTEGER NOT NULL,
    random_cannabis_bid                      UUID    NOT NULL,
    random_cannabis_strain                   VARCHAR,
    random_cannabis_cannabinoid_abbreviation VARCHAR,
    random_cannabis_cannabinoid              VARCHAR,
    random_cannabis_terpene                  VARCHAR,
    random_cannabis_medical_use              VARCHAR,
    random_cannabis_health_benefit           VARCHAR,
    random_cannabis_category                 VARCHAR,
    random_cannabis_type                     VARCHAR,
    random_cannabis_buzzword                 VARCHAR,
    random_cannabis_brand                    VARCHAR,
    random_cannabis_lru_date                 TIMESTAMP,
    lru_date                                 TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT cannabis PRIMARY KEY (random_cannabis_bid, random_cannabis_type)
);
CREATE INDEX IF NOT EXISTS warehouse_random_cannabis_lru_date ON warehouse.random_cannabis (lru_date);



