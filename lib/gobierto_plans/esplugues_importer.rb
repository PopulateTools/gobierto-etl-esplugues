class EspluguesImporter
  def initialize(options = {})
    @site = Site.find_by domain: options[:domain]
    @plan_slug = options[:plan_slug]
    @file_path = options[:file_path]
    @data = JSON.parse(File.read(@file_path))
    @reset_previous_data = options[:reset_previous_data]
  end

  def reset_previous_data?
    @reset_previous_data
  end

  def initialize_plan
    @plan = GobiertoPlans::Plan.find_or_create_by(site: @site, slug: @plan_slug)

    if @plan.title_translations.blank?
      @plan.update_attribute(:title_translations, {"ca" => "Pla d'Actuació Municipal 2016-2019",
                                                   "es" => "Plan de Actuación Municipal 2016-2019",
                                                   "en" => "Municipal Action Plan 2016-2019"})
      @plan.update_attribute(:slug, "pam-2016-2019")
    end

    if @plan.plan_type.blank?
      @plan_type = GobiertoPlans::PlanType.where(site_id: @site.id).first ||
        GobiertoPlans::PlanType.create(name_translations: { "ca" => "pam", "es" => "pam", "en" => "pam" }, site_id: @site.id)
      @plan.update(plan_type: @plan_type)
    end

    if @plan.categories_vocabulary.blank?
      @plan.create_categories_vocabulary(name_translations: @plan.title_translations, site: @plan.site)
      @plan.update_attribute(:vocabulary_id, @plan.vocabulary_id)
    end
  end

  def initialize_categories
    check_plan
    @plan.categories_vocabulary.terms.destroy_all if reset_previous_data?
    initialize_actuation_categories

    configure_plan if reset_previous_data?
  end

  def initialize_nodes
    check_plan
    @plan.nodes.destroy_all if reset_previous_data?
    initialize_projects
    associate_projects
    initialize_actions
    associate_actions
  end

  protected

  def check_plan
    initialize_plan unless @plan
  end

  def initialize_actuation_categories
    @categories = {}

    @data["actuation_categories"].each do |actuation_category|
      level_names = [actuation_category["e_name"], actuation_category["l_name"], actuation_category["a_name"]]
      current_level = @plan
      level_names.each_with_index do |name, index|
        name = name.sub(/\d./, '')
        current_level = GobiertoPlans::CategoryTermDecorator.new(
          current_level.categories.where("#{ GobiertoCommon::Term.table_name }.name_translations @> ?::jsonb", { ca: name }.to_json).first ||
          current_level.categories.new(name_translations: { ca: name }).tap do |category|
            category.level = index
            category.vocabulary_id = @plan.categories_vocabulary.id
            if !category.valid? && (same_name_categories = @plan.categories_vocabulary.terms.with_name_translation(name, :ca)).exists?
              category.slug += "-#{ same_name_categories.count + 1 }"
            end
            category.save
          end
        )
      end
      @categories[actuation_category["a_key"]] = current_level
    end
  end

  def initialize_projects
    @plan.nodes.destroy_all if reset_previous_data?

    @projects = {}
    @data["projects"].each do |project|
      node = GobiertoPlans::Node.new.tap do |node|
        node.name_translations = {ca: project["name"]}
        node.status_translations = {ca: project["status"]}
        node.progress = project["progress"].to_i
        node.starts_at = project["starts_at"]
        node.ends_at = project["ends_at"]
        node.options = Hash.new.tap do |options|
          %w(interval
           starts_at_real
           ends_at_real
           priority
           suspended
           goals
           year
           technical_supervisor_area
           technical_supervisor_department
           last_evaluation_date
           last_evaluation_color
           last_evaluation_arguments
           last_evaluation_proposals
           economic_benefits
           social_benefits
           environmental_benefits
           actual_budget
           available_budget).each do |key|
            options[key] = project[key]
          end
          options["type"] = "project"
        end
        node.save
        @projects[project["p_key"]] = node
      end
    end
  end

  def initialize_actions
    @actions = {}

    @data["actions"].each do |action|
      node = GobiertoPlans::Node.new.tap do |node|
        node.name_translations = {ca: action["name"]}
        node.progress = action["progress"].to_i
        node.options = Hash.new.tap do |options|
          %w(starts_at description).each do |key|
            options[key] = action[key]
          end
          options["type"] = "action"
        end
        node.save
        @actions[action["a_key"]] = node
      end
    end
  end

  def associate_projects
    @data["projects_actuations"].each do |association|
      @projects[association["p_key"]].categories << @categories[association["a_key"]]
    end
  end

  def associate_actions
    @data["actions_actuations"].each do |association|
      @actions[association["action_key"]].categories << @categories[association["actuation_key"]]
    end
  end

  def configure_plan
    level_0_options = GobiertoPlans::Category.where(level: 0, plan: @plan).each_with_index.map do |category, i|
      logos = ["https://gobierto-populate-staging.s3.eu-west-1.amazonaws.com/site-9/gobierto_attachments/attachments/file-083c12fb-0fd6-4688-8088-962afb9f4b21/Bitmap4.png",
               "https://gobierto-populate-staging.s3.eu-west-1.amazonaws.com/site-9/gobierto_attachments/attachments/file-75ed3dcb-660f-4b57-8d39-dd99f3e19eb4/Bitmap3.png",
               "https://gobierto-populate-staging.s3.eu-west-1.amazonaws.com/site-9/gobierto_attachments/attachments/file-b7019520-562a-463d-a071-1d9a0cf7a0be/Bitmap2.png",
               "https://gobierto-populate-staging.s3.eu-west-1.amazonaws.com/site-9/gobierto_attachments/attachments/file-77e52c3f-0315-428a-80c4-5f7c0d9c17e5/Bitmap.png",
               "https://gobierto-populate-staging.s3.eu-west-1.amazonaws.com/site-9/gobierto_attachments/attachments/file-2778e2ef-dd0d-4aa6-beec-790fe73fc0f4/Bitmap5.png"]

      { "slug": category.slug,
        "logo": logos[i] }
    end

    option_keys = { "GOALS": {"ca": "Metes",
                              "es": "Objetivos",
                              "en": "Goals"},
                    "DESCRIPTION": {"ca": "Descripció",
                                    "es": "Descripción",
                                    "en": "Description"},
                    "TECHNICAL_SUPERVISOR_AREA": {"ca": "àrea de supervisió tècnica",
                                                  "es": "área de supervisor técnico",
                                                  "en": "technical supervisor area"},
                    "TECHNICAL_SUPERVISOR_DEPARTMENT": {"ca": "departament de supervisió tècnica",
                                                        "es": "departamento de supervisor técnico",
                                                        "en": "technical supervisor department"}}

    @plan.update_attribute(:configuration_data, JSON.pretty_generate({
      "level0": {"one": {"ca": "eix", "es": "eje", "en": "axis"},
                 "other": {"ca": "eixos", "es": "ejes", "en": "axes"}},
      "level1": {"one": {"ca": "línia d'actuació", "es": "línea de actuación", "en": "line of action"},
                 "other": {"ca": "línies d'actuació", "es": "líneas de actuación", "en": "lines of action"}},
      "level2": {"one": {"ca": "actuació", "es": "actuación", "en": "action"},
                 "other": {"ca": "actuacions", "es": "actuaciones", "en": "actions"}},
      "level3": {"one": {"ca": "projecte/acció", "es": "proyecto/acción", "en": "project/action"},
                 "other": {"ca": "projectes/accions", "es": "proyectos/acciones", "en": "projects/actions"}},
      "level0_options": level_0_options,
      "option_keys": option_keys,
      "show_table_header": false,
      "open_node": false }))
  end
end
