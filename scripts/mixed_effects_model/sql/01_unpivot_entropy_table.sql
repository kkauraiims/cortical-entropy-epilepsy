/* Alter the SE table to include hours */
ALTER TABLE sample_ent_week1
ADD COLUMN hour INTEGER;

UPDATE sample_ent_week1
SET hour = rowid;

SELECT *
FROM sample_ent_week1
LIMIT 10;

/* Unpivot the entropy table */

DROP VIEW IF EXISTS entropy_long;
CREATE VIEW entropy_long AS

WITH unpivoted AS (

    SELECT hour, 'cont1' AS rodent_id, 'Control' AS group_name,
           cont1 AS sampen
    FROM sample_ent_week1

    UNION ALL

    SELECT hour, 'cont2', 'Control', cont2
    FROM sample_ent_week1

    UNION ALL

    SELECT hour, 'cont3', 'Control', cont3
    FROM sample_ent_week1

    UNION ALL

    SELECT hour, 'cont4', 'Control', cont4
    FROM sample_ent_week1

    UNION ALL

    SELECT hour, 'cont5', 'Control', cont5
    FROM sample_ent_week1

    UNION ALL

    SELECT hour, 'lg1', 'LGI1', lg1
    FROM sample_ent_week1

    UNION ALL

    SELECT hour, 'lg2', 'LGI1', lg2
    FROM sample_ent_week1

    UNION ALL

    SELECT hour, 'lg3', 'LGI1', lg3
    FROM sample_ent_week1

    UNION ALL

    SELECT hour, 'lg4', 'LGI1', lg4
    FROM sample_ent_week1

    UNION ALL

    SELECT hour, 'lg5', 'LGI1', lg5
    FROM sample_ent_week1
)

SELECT
    hour,
    CAST((hour - 1) / 24 AS INTEGER) + 1 AS recording_day,
    (hour - 1) % 24 AS hour_of_day,
    rodent_id,
    group_name,
    sampen
FROM unpivoted;


/* check the n_entries */
SELECT COUNT(*) AS total_rows
FROM entropy_long;

/* export as csv */
CREATE TABLE se_long_table AS
SELECT *
FROM entropy_long
ORDER BY rodent_id, hour; 
