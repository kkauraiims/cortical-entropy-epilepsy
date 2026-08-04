DROP TABLE IF EXISTS entropy_long;

CREATE TABLE entropy_long AS

WITH unpivoted AS (

    SELECT hour, 'cont1' AS rodent_id,
           'Control' AS group_name, cont1 AS sampen
    FROM se_data_clean

    UNION ALL
    SELECT hour, 'cont2', 'Control', cont2
    FROM se_data_clean

    UNION ALL
    SELECT hour, 'cont3', 'Control', cont3
    FROM se_data_clean

    UNION ALL
    SELECT hour, 'cont4', 'Control', cont4
    FROM se_data_clean

    UNION ALL
    SELECT hour, 'cont5', 'Control', cont5
    FROM se_data_clean

    UNION ALL
    SELECT hour, 'lg1', 'LGI1', lg1
    FROM se_data_clean

    UNION ALL
    SELECT hour, 'lg2', 'LGI1', lg2
    FROM se_data_clean

    UNION ALL
    SELECT hour, 'lg3', 'LGI1', lg3
    FROM se_data_clean

    UNION ALL
    SELECT hour, 'lg4', 'LGI1', lg4
    FROM se_data_clean

    UNION ALL
    SELECT hour, 'lg5', 'LGI1', lg5
    FROM se_data_clean
)

SELECT
    hour,
    CAST((hour - 1) / 24 AS INTEGER) + 1 AS recording_day,
    (hour - 1) % 24 AS hour_of_day,
    rodent_id,
    group_name,
    sampen
FROM unpivoted;

SELECT COUNT(*) AS total_rows
FROM entropy_long;

/* export as csv */
CREATE TABLE se_long_table AS
SELECT *
FROM entropy_long
ORDER BY rodent_id, hour; 
