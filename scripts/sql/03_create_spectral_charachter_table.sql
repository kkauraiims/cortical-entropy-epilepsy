REATE TABLE entropy_spectral AS

SELECT *
FROM absolute_pow_bands AS a

LEFT JOIN relative_pow_bands AS r 
USING (subject)

LEFT JOIN entropy_signalVariance AS e

USING (subject); 
