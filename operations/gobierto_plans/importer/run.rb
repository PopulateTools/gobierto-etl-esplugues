#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require
require "json"

require_relative "../../../lib/gobierto_plans/esplugues_importer"

# This scripts iports PAM data from Ajuntament d'Esplugues
#
# It has four arguments:
#
# - Filename containing of the site where the data are being imported
# - Domain of the site where the data are being imported
# - Slug of the plan
# - Reset previous_data. false by default, use reset_previous_data keyword
#
# Usage:

#   bin/rails runner <absolute_path_to_script> <path_to_json_file> <site_domain> <plan_slug> [reset_previous_data]
# It's expected to be executed as a runner of Gobierto. Example:
# ./bin/rails runner ~/proyectos/populate/populate-data-indicators/private_data/gobierto/esplugues/recurring/import_pam.rb ~/proyectos/populate/populate-data-indicators/data_sources/private/gobierto/esplugues/pam/pam_esplugues.json cortegada.gobierto.dev pam-2016-2019 reset_previous_data

file_path = ARGV[0]
domain = ARGV[1]
plan_slug = ARGV[2]
reset_previous_data = (ARGV[3] == "reset_previous_data")

@site = Site.find_by domain: domain

if plan_slug.blank? || (ARGV[3].blank? && plan_slug == "reset_previous_data")
  puts " - Error: a slug for plan must be provided. Usage: import_pam json_data_file domain plan_slug [reset_previous_data]"
  puts " - Available slugs: #{@site.plans.pluck(:slug).join(", ")}"
  exit(0)
end

@site = Site.find_by domain: domain
@plan = GobiertoPlans::Plan.find_or_create_by(site: @site, slug: plan_slug)

puts "== Running Esplugues import_pam for #{@site.domain}"

puts "===== Loading data..."
importer = EspluguesImporter.new(domain: domain, file_path: file_path, plan_slug: plan_slug, reset_previous_data: reset_previous_data)

ActiveRecord::Base.transaction do
  puts "===== Creating/updating plan..."
  importer.initialize_plan
  puts "===== Creating/updating categories..."
  importer.initialize_categories
  puts "===== Creating/updating nodes..."
  importer.initialize_nodes
end

puts "== Import finished"

puts "You have to generate category progress and uid using these commands:"
puts <<-COMMANDS

bin/rake gobierto_plans:category:progress_cache[#{plan_slug}]
bin/rake gobierto_plans:category:uid_cache[#{plan_slug}]
COMMANDS
