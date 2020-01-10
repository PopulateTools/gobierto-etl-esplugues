#!/bin/bash

set -e

WORKING_DIR=/tmp/esplugues
GOBIERTO_ETL_UTILS=$DEV_DIR/gobierto-etl-utils
ESPLUGUES_ETL=$DEV_DIR/gobierto-etl-esplugues
GOBIERTO=$DEV_DIR/gobierto
ESPLUGUES_ID=8077

# Clear working dir
rm -rf $WORKING_DIR

# Extract > Download data sources
cd $GOBIERTO_ETL_UTILS; ruby operations/download-s3/run.rb "esplugues/providers" $WORKING_DIR

# Extract > Convert to UTF8
for file in $WORKING_DIR/*
do
  cd $GOBIERTO_ETL_UTILS; ruby operations/convert-to-utf8/run.rb $file $file"_utf8"
done

# Extract > Check CSV format
for file in $WORKING_DIR/*_utf8
do
  cd $GOBIERTO_ETL_UTILS; ruby operations/check-csv/run.rb $file
done

# Load > Remove previous data
cd $GOBIERTO_ETL_UTILS; ruby operations/gobierto_budgets/clear-previous-providers/run.rb $ESPLUGUES_ID

# Load > Transform providers and invoices data
for file in $WORKING_DIR/*_utf8
do
  cd $ESPLUGUES_ETL; ruby operations/gobierto_budgets/transform-providers/run.rb $ESPLUGUES_ID $file $file"_transformed.json"
done

# Load > Load providers and invoices data
for file in $WORKING_DIR/*_transformed.json
do
  cd $GOBIERTO_ETL_UTILS; ruby operations/gobierto_budgets/import-invoices/run.rb $file
done


# Load > Publish activity
echo $ESPLUGUES_ID > $WORKING_DIR/organization.id.txt
cd $GOBIERTO; bin/rails runner $GOBIERTO_ETL_UTILS/operations/gobierto/publish-activity/run.rb providers_updated $WORKING_DIR/organization.id.txt
