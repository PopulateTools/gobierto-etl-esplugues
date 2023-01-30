#!/bin/bash

# Documentation
#
# https://drive.google.com/file/d/1U23HS_EQQwv8C-mcC-0rjAQiFFA_kJI2/view

WORKING_DIR=/tmp/geo_equipamientos
ETL_UTILS=$DEV_DIR/gobierto-etl-utils
ETL=$DEV_DIR/gobierto-etl-esplugues
GOBIERTO_URL=$1
place_id=8077

# Clean working dir
cd $ETL_UTILS; ruby operations/prepare-working-directory/run.rb $WORKING_DIR

# Download data in CSV format
table_list="atencio_social cultura ensenyament esplais_jubilats esport mercats residencies_geriatriques salut"

for table in $table_list; do
  echo "Processing $table"
  cd $ETL_UTILS; ruby operations/download/run.rb "https://mun.nexusgeographics.com/geoserver/esplugues/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=esplugues%3A${table}&maxFeatures=10000&outputFormat=csv" $WORKING_DIR/${table}_raw.csv
  ruby operations/load-csv-sqlite/run.rb $WORKING_DIR/${table}_raw.csv $WORKING_DIR/data.sqlite ',' ${table}_raw
done
# Transform > Apply transform template
sed "s/<place_id>/${place_id}/g" $ETL/datasets/geo-equipamientos/transform.sql  ${WORKING_DIR}/transform.sql

# Transform > Apply transform queries
cd $ETL_UTILS; ruby operations/apply-sqlite-transform/run.rb $WORKING_DIR/transform.sql $WORKING_DIR/data.sqlite

# Transform > Extract CSV from SQLite
cd $ETL_UTILS; ruby operations/export-sqlite-csv/run.rb $WORKING_DIR/data.sqlite $WORKING_DIR/data.csv

# Load
cd $ETL_UTILS;
ruby operations/gobierto_data/upload-dataset/run.rb \
  --api-token $GOBIERTO_API_TOKEN \
  --gobierto-url $GOBIERTO_URL \
  --name "Equipamientos" \
  --slug "geo-equipamientos" \
  --table-name "geo-equipamientos" \
  --schema-path $ETL/datasets/geo-equipamientos/schema.json \
  --file-path  $WORKING_DIR/data.csv
