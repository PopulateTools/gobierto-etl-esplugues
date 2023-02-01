DROP VIEW IF EXISTS data;
CREATE VIEW data AS
  SELECT FID as id 
  ,nom as "equipment_name"
  ,tipus as "equipment_type"
  ,adreça || '. ' || cp_pobl as "location"
  ,correu as "email" 
  ,telefon as phone_number
  ,geom as geometry
  FROM atencio_social_raw
  
UNION ALL 
  SELECT FID as id 
  ,nom as "equipment_name"
  ,tipus as "equipment_type"
  ,adreça || '. ' || cp_pobl as "location"
  ,correu as "email" 
  ,telefon as phone_number
  ,geom as geometry 
  FROM cultura_raw

UNION ALL 
  SELECT FID as id 
  ,nom as "equipment_name"
  ,tipus as "equipment_type"
  ,adreça || '. ' || cp_pobl as "location"
  ,correu as "email" 
  ,telefon as phone_number
  ,geom as geometry
  FROM ensenyament_raw

UNION ALL 
  SELECT FID as id 
  ,nom as "equipment_name"
  ,tipus as "equipment_type"
  ,adreça || '. ' || cp_pobl as "location"
  ,correu as "email" 
  ,telefon as phone_number
  ,geom as geometry 
  FROM esplais_jubilats_raw

UNION ALL 
  SELECT FID as id 
  ,nom as "equipment_name"
  ,tipus as "equipment_type"
  ,adreça || '. ' || cp_pobl as "location"
  ,correu as "email" 
  ,telefon as phone_number
  ,geom as geometry 
  FROM esport_raw

UNION ALL 
  SELECT FID as id 
  ,nom as "equipment_name"
  ,tipus as "equipment_type"
  ,adreça || '. ' || cp_pobl as "location"
  ,correu as "email" 
  ,telefon as phone_number
  ,geom as geometry 
  FROM mercats_raw

UNION ALL 
  SELECT FID as id 
  ,nom as "equipment_name"
  ,tipus as "equipment_type"
  ,adreça || '. ' || cp_pobl as "location"
  ,correu as "email" 
  ,telefon as phone_number
  ,geom as geometry 
  FROM residencies_geriatriques_raw

UNION ALL 
  SELECT FID as id 
  ,nom as "equipment_name"
  ,tipus as "equipment_type"
  ,adreça || '. ' || cp_pobl as "location"
  ,correu as "email" 
  ,telefon as phone_number
  ,geom as geometry 
  FROM salut_raw;
