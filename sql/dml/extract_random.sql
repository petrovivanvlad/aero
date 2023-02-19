
/* UPSERT не используется потому что простой DELETE + INSERT работает быстрее */
/* UPSERT нет в Greenplum (Postgre v9) */

-- 1. Наполянем снапшот:
TRUNCATE    staging.random_cannabis_snapshot;
INSERT INTO staging.random_cannabis_snapshot
    (
     id,
     bid,
     data,
     lru_date
     )
SELECT
     id,
     bid,
     data,
     lru_date
FROM staging.random_cannabis
-- LIMIT  -- TODO: указать размер батча будет предпочтительно
;

-- 2. Удаляем старые сообщения (если uuid совпадает):
DELETE
FROM  warehouse.random_cannabis          AS tgt
USING   staging.random_cannabis_snapshot AS src
WHERE tgt.random_cannabis_bid = src.bid;

-- 3. Лъем новые данные:
INSERT INTO warehouse.random_cannabis
    (
     random_cannabis_id,
     random_cannabis_bid,
     random_cannabis_strain,
     random_cannabis_cannabinoid_abbreviation,
     random_cannabis_cannabinoid,
     random_cannabis_terpene,
     random_cannabis_medical_use,
     random_cannabis_health_benefit,
     random_cannabis_category,
     random_cannabis_type,
     random_cannabis_buzzword,
     random_cannabis_brand,
     random_cannabis_lru_date,
     lru_date
     )
SELECT
    (src.data ->> 'id')::INTEGER            AS random_cannabis_id,
    (src.data ->> 'uid')::UUID     AS random_cannabis_bid,
    src.data ->> 'strain'                   AS random_cannabis_strain,
    src.data ->> 'cannabinoid_abbreviation' AS random_cannabis_cannabinoid_abbreviation,
    src.data ->> 'cannabinoid'              AS random_cannabis_cannabinoid,
    src.data ->> 'terpene'                  AS random_cannabis_terpene,
    src.data ->> 'medical_use'              AS random_cannabis_medical_use,
    src.data ->> 'health_benefit'           AS random_cannabis_health_benefit,
    src.data ->> 'category'                 AS random_cannabis_category,
    src.data ->> 'type'                     AS random_cannabis_type,
    src.data ->> 'buzzword'                 AS random_cannabis_buzzword,
    src.data ->> 'id'                       AS random_cannabis_brand,
    lru_date                                AS random_cannabis_lru_date,
    CURRENT_TIMESTAMP	                    AS lru_date
FROM staging.random_cannabis src;

-- 4. Лъем новые данные в архив:
INSERT INTO staging.random_cannabis_processed
    (
     id,
     bid,
     data,
     lru_date,
     processing_date
    )
SELECT
    id,
    bid,
    data,
    lru_date,
    CURRENT_TIMESTAMP
FROM staging.random_cannabis_snapshot;

-- 5. Удаляем обработанные данные:
DELETE
FROM  staging.random_cannabis          AS tgt
USING staging.random_cannabis_snapshot AS snap
WHERE tgt.bid = snap.bid;

