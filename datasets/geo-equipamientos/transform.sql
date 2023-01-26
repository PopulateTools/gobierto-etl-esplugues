DROP VIEW IF EXISTS data;
CREATE VIEW data AS
  SELECT FID as id 
  ,nom as "equipment_name"
  ,tipus as "equipment_type"
  ,CONCAT(adreça,'. ', cp_pobl) as "location"
  ,correu as "email" 
  ,telefon as phone_number
  ,geom 
  FROM atencio_social_raw
  
UNION ALL 
  SELECT FID as id 
  ,nom as "equipment_name"
  ,tipus as "equipment_type"
  ,CONCAT(adreça,'. ', cp_pobl) as "location"
  ,correu as "email" 
  ,telefon as phone_number
  ,geom 
  FROM cultura_raw

UNION ALL 
  SELECT FID as id 
  ,nom as "equipment_name"
  ,tipus as "equipment_type"
  ,CONCAT(adreça,'. ', cp_pobl) as "location"
  ,correu as "email" 
  ,telefon as phone_number
  ,geom 
  FROM ensenyament_raw

UNION ALL 
  SELECT FID as id 
  ,nom as "equipment_name"
  ,tipus as "equipment_type"
  ,CONCAT(adreça,'. ', cp_pobl) as "location"
  ,correu as "email" 
  ,telefon as phone_number
  ,geom 
  FROM ensenyament_raw

UNION ALL 
  SELECT FID as id 
  ,nom as "equipment_name"
  ,tipus as "equipment_type"
  ,CONCAT(adreça,'. ', cp_pobl) as "location"
  ,correu as "email" 
  ,telefon as phone_number
  ,geom 
  FROM esplais_jubilats_raw

UNION ALL 
  SELECT FID as id 
  ,nom as "equipment_name"
  ,tipus as "equipment_type"
  ,CONCAT(adreça,'. ', cp_pobl) as "location"
  ,correu as "email" 
  ,telefon as phone_number
  ,geom 
  FROM esport_raw

UNION ALL 
  SELECT FID as id 
  ,nom as "equipment_name"
  ,tipus as "equipment_type"
  ,CONCAT(adreça,'. ', cp_pobl) as "location"
  ,correu as "email" 
  ,telefon as phone_number
  ,geom 
  FROM mercats_raw

UNION ALL 
  SELECT FID as id 
  ,nom as "equipment_name"
  ,tipus as "equipment_type"
  ,CONCAT(adreça,'. ', cp_pobl) as "location"
  ,correu as "email" 
  ,telefon as phone_number
  ,geom 
  FROM residencies_geriatriques_raw

UNION ALL 
  SELECT FID as id 
  ,nom as "equipment_name"
  ,tipus as "equipment_type"
  ,CONCAT(adreça,'. ', cp_pobl) as "location"
  ,correu as "email" 
  ,telefon as phone_number
  ,geom 
  FROM salut_raw
