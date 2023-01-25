#!/bin/bash

# Documentation 
#
# https://drive.google.com/file/d/1U23HS_EQQwv8C-mcC-0rjAQiFFA_kJI2/view

set -e
source .env

WORKING_DIR=/tmp/geo_paradas
ETL_UTILS=$DEV_DIR/gobierto-etl-utils
ETL=$DEV_DIR/gobierto-etl-datos
GOBIERTO_URL=$1
YEAR=2022

# Clean working dir
cd $ETL_UTILS; ruby operations/prepare-working-directory/run.rb $WORKING_DIR

# Download data in CSV format
table_list = ['bus', 'trambaix', 'metro']

for table in table_list
  cd $ETL_UTILS; ruby operations/download/run.rb "https://mun.nexusgeographics.com/geoserver/esplugues/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=esplugues%3A${table}&maxFeatures=10000&outputFormat=csv" $WORKING_DIR/${table}_raw.csv

# Transform > Apply transform template
sed "s/<table>/${table}/g" $ETL/datasets/geo_paradas/transform_template.sql > ${WORKING_DIR}/transform.sql

# Transform > Apply transform queries
cd $ETL_UTILS; ruby operations/apply-sqlite-transform/run.rb $WORKING_DIR/transform.sql $WORKING_DIR/data.sqlite

# Transform > Extract CSV from SQLite
cd $ETL_UTILS; ruby operations/export-sqlite-csv/run.rb $WORKING_DIR/data.sqlite $WORKING_DIR/data.csv

# Load
cd $ETL_UTILS;
ruby operations/gobierto_data/upload-dataset/run.rb \
  --api-token $GOBIERTO_API_TOKEN \
  --gobierto-url $GOBIERTO_URL \
  --name "Paradas" \
  --slug "geo-paradas" \
  --table-name "geo-paradas" \
  --schema-path $ETL/datasets/geo-paradas/schema.json \
  --file-path  $WORKING_DIR/data.csv
