DROP VIEW IF EXISTS data;
CREATE VIEW data AS
  SELECT FID as id 
  ,COALESCE(nom, adreça) as "name"
  ,tipus as "type"
  ,adreça as "location"
  ,geom as geometry 
  FROM bus_raw
  
  UNION ALL 
  SELECT FID as id 
  ,nom as "name"
  ,tipus as "type"
  ,adreça as "location"
  ,geom as geometry 
  FROM trambaix_raw

  UNION ALL 
  SELECT FID as id 
  ,nom as "name"
  ,tipus as "type"
  ,adreça as "location"
  ,geom as geometry 
  FROM metro_raw;
