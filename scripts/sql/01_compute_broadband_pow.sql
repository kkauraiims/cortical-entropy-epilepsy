SELECT
subject,
delta,
theta,
alpha,
beta,
gamma,
delta+ theta+ alpha+ beta+ gamma AS broadband_power
FROM  absolute_pow_bands; 
