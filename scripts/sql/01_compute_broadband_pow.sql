ALTER TABLE absolute_pow_bands
ADD COLUMN broadband_power REAL; 

UPDATE absolute_pow_bands
SET broadband_power= delta+theta+alpha+beta+gamma; 

SELECT *
FROM absolute_pow_bands;
