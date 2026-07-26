DROP VIEW IF EXISTS seizures_long;
CREATE VIEW seizures_long AS

WITH unpivoted AS (
SELECT hour, 'lg1' as rodent_id, lg1 as sf
FROM lg1_seizures

UNION ALL 

SELECT hour, 'lg2', lg2
FROM lg1_seizures

UNION ALL 

SELECT hour, 'lg3', lg3
FROM lg1_seizures

UNION ALL 

SELECT hour, 'lg4', lg4
FROM lg1_seizures

UNION ALL 

SELECT hour, 'lg5', lg5
FROM lg1_seizures

)
SELECT 
hour, 
CAST((hour - 1) / 24 AS INTEGER) + 1 AS recording_day,
    (hour - 1) % 24 AS hour_of_day,
    rodent_id,
	sf 
	FROM unpivoted; 

CREATE TABLE sf_long_table AS
SELECT *
FROM seizures_long 
ORDER BY rodent_id, hour; 
  
