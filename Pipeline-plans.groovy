email = "popu-servers+jenkins@populate.tools "
pipeline {
    agent any
    environment {
        PATH = "/home/ubuntu/.rbenv/shims:$PATH"
        GOBIERTO_ETL_UTILS = "/var/www/gobierto-etl-utils/current/"
        ESPLUGUES_ETL = "/var/www/gobierto-etl-esplugues/current/"
        GOBIERTO = "/var/www/gobierto/current/"
        WORKING_DIR="/tmp/esplugues"
        ESPLUGUES_DOMAIN="portalobert.esplugues.cat"
        PAM_SLUG="pam-2016-2019"
    }
    stages {
        stage('Extract > Download data sources') {
            steps {
                sh "cd ${ESPLUGUES_ETL}; ruby operations/gobierto_plans/extractor/run.rb ${WORKING_DIR}/plan.json"
            }
        }
        stage('Extract > Check JSON format') {
            steps {
                sh "cd ${GOBIERTO_ETL_UTILS}; ruby operations/check-json/run.rb ${WORKING_DIR}/plan.json"
            }
        }
        stage('Load > Import plans') {
            steps {
                sh "cd ${GOBIERTO}; bin/rails runner ${ESPLUGUES_ETL}/operations/gobierto_plans/importer/run.rb ${WORKING_DIR}/plan.json ${ESPLUGUES_DOMAIN} ${PAM_SLUG}"
            }
        }
        stage('Load > Update caches') {
            steps {
                sh "cd ${GOBIERTO}; bin/rails gobierto_plans:category:progress_cache[${PAM_SLUG}]"
                sh "cd ${GOBIERTO}; bin/rails gobierto_plans:category:uid_cache[${PAM_SLUG}]"
            }
        }
    }
    post {
        failure {
            echo 'This will run only if failed'
            mail body: "Project: ${env.JOB_NAME} - Build Number: ${env.BUILD_NUMBER} - URL de build: ${env.BUILD_URL}",
                charset: 'UTF-8',
                subject: "ERROR CI: Project name -> ${env.JOB_NAME}",
                to: email

        }
    }
}
