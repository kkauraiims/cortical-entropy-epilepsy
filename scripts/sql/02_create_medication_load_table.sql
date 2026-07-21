CREATE TABLE medication_load_32 AS

SELECT
m.subject,
m.n_aed, 
m.benzodiazepine, 
m.barbiturates

FROM entropy_medication_load AS m

INNER JOIN absolute_pow_bands AS p
ON m.subject=p.subject;
