#!/bin/bash

# Extract > Download data sources
cd $DEV/gobierto-etl-esplugues/; ruby operations/gobierto_plans/extractor/run.rb /tmp/esplugues/plan.json

# Extract > Check JSON format
cd $DEV/gobierto-etl-utils/; ruby operations/check-json/run.rb /tmp/esplugues/plan.json

# Load > Import plans
cd $DEV/gobierto; bin/rails runner $DEV/gobierto-etl-esplugues/operations/gobierto_plans/importer/run.rb /tmp/esplugues/plan.json esplugues.gobify.net pam-2016-2019 reset_previous_data

# # Load > Update caches
# cd $DEV/gobierto; bin/rails gobierto_plans:category:progress_cache[pam-2016-2019]
# cd $DEV/gobierto; bin/rails gobierto_plans:category:uid_cache[pam-2016-2019]

# # Load > Publish activity
# cd /Users/fernando/proyectos/gobierto/; bin/rails runner /Users/fernando/proyectos/gobierto-etl-utils/operations/gobierto/publish-activity/run.rb budgets_updated /tmp/mataro/organization.id.txt
