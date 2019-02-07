#!/bin/bash

XBRL_FILE="AJ-TrimLoc-20181t.xbrl"

# Extract > Download data sources
cd $DEV_DIR/gobierto-etl-utils/; ruby operations/download-s3/run.rb "esplugues/budgets/$XBRL_FILE" /tmp/esplugues/

cd $DEV_DIR/gobierto-etl-utils/; ruby operations/gobierto_budgets/xbrl/trimloc/transform-execution/run.rb operations/gobierto_budgets/xbrl/dictionaries/xbrl_trimloc_dictionary.yml /tmp/esplugues/$XBRL_FILE 8077 2018 /tmp/esplugues/budgets-execution-2018.json

cd $DEV_DIR/gobierto-etl-utils/; ruby operations/gobierto_budgets/import-executed-budgets/run.rb /tmp/esplugues/budgets-execution-2018.json 2018

# Load > Calculate totals
echo "8077" > /tmp/esplugues/organization.id.txt
cd $DEV_DIR/gobierto-etl-utils/; ruby operations/gobierto_budgets/update_total_budget/run.rb "2018" /tmp/esplugues/organization.id.txt

# Load > Calculate bubbles
cd $DEV_DIR/gobierto-etl-utils/; ruby operations/gobierto_budgets/bubbles/run.rb /tmp/esplugues/organization.id.txt

# Load > Calculate annual data
cd $DEV_DIR/gobierto/; bin/rails runner $DEV_DIR/gobierto-etl-utils/operations/gobierto_budgets/annual_data/run.rb "2018" /tmp/esplugues/organization.id.txt

# Load > Publish activity
cd $DEV_DIR/gobierto/; bin/rails runner $DEV_DIR/gobierto-etl-utils/operations/gobierto/publish-activity/run.rb budgets_updated /tmp/esplugues/organization.id.txt
