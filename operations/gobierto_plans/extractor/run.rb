#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require
require "json"

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Destination file name
#
# Samples:
#
#   /path/to/project/operations/gobierto_plans/extractor/run.rb /tmp/output.json
#

if ARGV.length != 1
  raise "Review the arguments"
end

destination_file_name = ARGV[0]

if File.dirname(destination_file_name) != "."
  FileUtils.mkdir_p(File.dirname(destination_file_name))
end


def compact_query(query)
  query.map{ |e| e.tap {|j| j.each_key {|k| j[k] = j[k].strip if j[k].is_a?(String) } } }
end

def generate_query(sql, client = nil, encoding = 'UTF-8')
  empty_client = client.nil?
  client ||= TinyTds::Client.new username: ENV.fetch("USERNAME"), password: ENV.fetch("PASSWORD"), host: ENV.fetch("HOST"), encoding: encoding
  request = client.execute(sql)
  result = compact_query(request)
  request.cancel
  client.close if empty_client
  return result
end

def extract_actuations_categories
  query = <<-SQL
    select
    a.codi as a_key,
    a.actuacio as a_name,
    a.quinsentit as a_purpose,
    Convert(Bit, case desplegament when "Si" then 1 else 0 end) as a_projects_breakdown,
    Convert(Bit, case desplegament when "Si" then 0 else 1 end) as a_actuations_breakdown,
    l.codi as l_key,
    l.descripcio as l_name,
    e.codi as e_key,
    e.descripcio as e_name
    from eix e
    join linea l
    on l.eix_codi = e.codi
    join actuacions a
    on l.codi = a.linea_codi
    order by e_key ASC, l_key ASC, a_key ASC
    SQL

  generate_query(query)
end

def extract_plas_categories
  query = <<-SQL
    select
    p.codi as pla_key,
    p.descrip  as name,
    p.estat as status,
    p.inici as start_date,
    p.fi as end_date
    from pla p
    SQL

  generate_query(query)
end

def extract_services_categories
  query = <<-SQL
    select
    s.codi as s_key,
    s.nom as name,
    s.observacions as purpose,
    Convert(Bit, case s.tipus_servei when "S" then 1 else 0 end) as service,
    Convert(Bit, case s.tipus_servei when "P" then 1 else 0 end) as allowance,
    s.tipus_servei_codi as parent_s_key,
    s.estat as status,
    c.nom as r_name,
    c.descrip as r_description,
    c.estat as r_status,
    prc.nom as p_name,
    prc_t.nom as p_type,
    pla.descrip as pla_description,
    pla.estat as pla_status,
    pla.inici as pla_starts_at,
    pla.fi as pla_ends_at
    from
    servei s
    left outer join competencia_servei c on s.competencia_codi = c.codi
    left outer join proces prc on s.codproces = prc.codi
    left outer join pla on s.codipla = pla.codi
    join tipproces prc_t on prc.coditiproces = prc_t.codi
    SQL

  generate_query(query)
end

def extract_projects
query = <<-SQL
  select
    p.numidclau as p_key,
    p.codiprojecte as p_code,
    p.descripproj as name,
    p.evolucio_proj as progress,
    p.estat as status,
    p.datainiprevista as starts_at,
    p.datafiprevista as ends_at,
    p.datainicireal as starts_at_real,
    p.datafireal as ends_at_real,
    p.codipla as pla_key,
    pla.descrip as pla_description,
    pla.estat as pla_status,
    pla.inici as pla_starts_at,
    pla.fi as pla_ends_at,
    case p.temporalitat
      when 1 then "Anual"
      when 2 then "Bianual"
      when 3 then "Triennal"
      else "Quadriennal"
    end as interval,
    Convert(Bit, case p.suspes when "SI" then 1 else 0 end) as suspended,
    p.prioritat as priority,
    p.objectius as goals,
    p.exercici as year,
    p.area_resptecnic as technical_supervisor_area,
    p.dep_resptecnic as technical_supervisor_department,
    p.uv_data as last_evaluation_date,
    p.uv_semafor as last_evaluation_color,
    p.uv_argument as last_evaluation_arguments,
    p.uv_passes as last_evaluation_proposals,
    p.benef_eco as economic_benefits,
    p.benef_social as social_benefits,
    p.benef_ambiental as environmental_benefits,
    p.press_real as actual_budget,
    p.press_dispo as available_budget
    from
    projectes p left outer join pla on p.codipla = pla.codi
    SQL

  generate_query(query)
end

def extract_actions
  query = <<-SQL
    select
    aa.accio_iddoc as a_key,
    aa.accio_codi as a_code,
    aa.accio_nom as name,
    aa.accio_descrip as description,
    aa.accio_data as starts_at,
    "100" as progress,
    aa.accio_clau_actuacio as actuation_key
    from actuacions_accions aa
    SQL

  generate_query(query)
end

def extract_projects_actuations
  query = <<-SQL
    select
    pa.clauprojecte as p_key,
    pa.codi_act as a_key
    from
    projecte_actuacio pa
    SQL

  generate_query(query)
end

def extract_projects_plas
  query = <<-SQL
    select
    pp.codipla as pla_key,
    pp.numidclau as p_key
    from
    projectes pp
    SQL

  generate_query(query)
end

def extract_projects_services
  query = <<-SQL
    select
    ps.codiservei as s_key,
    ps.codiprojecte as p_key
    from
    projecte_servei ps
    SQL

  generate_query(query)
end

def extract_actions_actuations
  query = <<-SQL
    select
    aa.accio_iddoc as action_key,
    a.codi as actuation_key
    from
    actuacions_accions aa
    join actuacions a on aa.accio_clau_actuacio = a.iddoc
    SQL
  generate_query(query)
end

def generate_json
  return JSON.generate({
    actuation_categories: extract_actuations_categories,
    projects: extract_projects,
    actions: extract_actions,
    projects_actuations: extract_projects_actuations,
    actions_actuations: extract_actions_actuations,
    other_projects_classifications: {
      services: {
        service_categories: extract_services_categories,
        projects_services: extract_projects_services
      },
      plas: {
        plas_categories: extract_plas_categories,
        projects_plas: extract_projects_plas
      }
    }
  })
end

def export_data(filename)
  File.open(filename, 'wb+') do |fd|
    fd.write(generate_json)
  end
end

export_data(destination_file_name)
