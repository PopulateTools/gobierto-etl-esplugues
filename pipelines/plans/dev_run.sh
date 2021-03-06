#!/bin/bash

WORKING_DIR=/tmp/esplugues

# Extract > Download data sources
cd $DEV_DIR/gobierto-etl-esplugues; ruby operations/gobierto_plans/extractor/run.rb $WORKING_DIR/plan.json

# Extract > Check JSON format
cd $DEV_DIR/gobierto-etl-utils; ruby operations/check-json/run.rb $WORKING_DIR/plan.json

# Load > Import plans
cd $DEV_DIR/gobierto; bin/rails runner $DEV_DIR/gobierto-etl-esplugues/operations/gobierto_plans/importer/run.rb $WORKING_DIR/plan.json esplugues.gobify.net pam-2016-2019 reset_previous_data

# # Load > Update caches
# cd $DEV/gobierto; bin/rails gobierto_plans:category:progress_cache[pam-2016-2019]
# cd $DEV/gobierto; bin/rails gobierto_plans:category:uid_cache[pam-2016-2019]

# # Load > Publish activity
# cd /Users/fernando/proyectos/gobierto/; bin/rails runner /Users/fernando/proyectos/gobierto-etl-utils/operations/gobierto/publish-activity/run.rb budgets_updated /tmp/mataro/organization.id.txt
