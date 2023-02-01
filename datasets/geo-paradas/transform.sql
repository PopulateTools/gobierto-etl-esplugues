DROP VIEW IF EXISTS data;
CREATE VIEW data AS
  SELECT FID as id 
  ,adreça as "name"
  ,tipus as "type"
  ,adreça as "location"
  ,geom
  FROM bus_raw
  
  UNION ALL 
  SELECT FID as id 
  ,nom as "name"
  ,tipus as "type"
  ,adreça as "location"
  ,geom
  FROM trambaix_raw

  UNION ALL 
  SELECT FID as id 
  ,nom as "name"
  ,tipus as "type"
  ,adreça as "location"
  ,geom 
  FROM metro_raw;
