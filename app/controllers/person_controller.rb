# encoding: utf-8
class PersonController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    search_val = params[:search][:value] rescue nil
    search_val = '_' if search_val.blank?

    if !params[:start].blank?

      d = Person.order(" person.created_at DESC, person.village_of_birth, person.ta_of_birth, person.district_of_birth, person.first_name ")
        .where(" concat_ws('_', person.first_name, person.last_name, person.middle_name,
                          person.district_of_birth, person.ta_of_birth, person.village_of_birth,
                          person.mother_first_name, person.mother_middle_name, person.mother_last_name,
                          person.father_first_name, person.father_middle_name, person.father_last_name,
                          DATE_FORMAT(person.date_of_birth, '%d/%b/%Y'), person.gender) REGEXP \"#{search_val}\" ")

        total = d.select(" count(*) c ")[0]['c'] rescue 0
        page = (params[:start].to_i / params[:length].to_i) + 1

        data = d.group(" person.person_id ")
        data = data.page(page)
        .per_page(params[:length].to_i)

        @records = []
        data.each do |p|

          arr = [p.name,
                 p.date_of_birth.to_date.strftime('%d/%b/%Y'),
                 p.gender,
                 p.place_of_birth,
                 p.mother_name,
                 p.father_name,
                 p.person_id
          ]

        @records << arr
      end

      render json: {
          "draw" => params[:draw].to_i,
          "recordsTotal" => total,
          "recordsFiltered" => total,
          "data" => @records}.to_json and return
    end

    # @records = PersonService.query_for_display(@states)

    render :template => "/person/index"
  end

  def delete_all_records
    Person.delete_all
    redirect_to "/"
  end

  def new

    if @cur_user.role == 'Administrator'
      redirect_to '/home' and return
    end

    tag_id = LocationTag.where(name: 'District').last.id
    @districts = Location.joins(" join location_tag_map m ON m.location_id = location.location_id ")
    .where(" m.location_tag_id = #{tag_id} ").order("name")

    @person = Person.new

    tag_id = LocationTag.where(name: "Country").first.id
    @countries = Location.find_by_sql(
        "SELECT l.name FROM location l INNER JOIN location_tag_map m ON l.location_id = m.location_id  WHERE m.location_tag_id = #{tag_id} ").collect{|s| s.name.force_encoding('utf-8').encode}

    locations = Location.find_by_sql(
        "SELECT l.country FROM location l INNER JOIN location_tag_map m ON l.location_id = m.location_id  WHERE m.location_tag_id = #{tag_id} ")

    @nationalities = locations.map(&:country)
    @action = '/person/new'
  end

  def suggest

    names = []
    if params[:field].match("first")
      names = (File.read("#{Rails.root}/app/assets/data/first_names.csv").split("\n") +
          Person.pluck("first_name") + Person.pluck("mother_first_name") + Person.pluck("father_first_name")).uniq.sort

    elsif params[:field].match("middle")
      names = (File.read("#{Rails.root}/app/assets/data/middle_names.csv").split("\n") +
          Person.pluck("middle_name") + Person.pluck("mother_middle_name") + Person.pluck("father_middle_name")).uniq.sort

    elsif params[:field].match("last")
      names = (File.read("#{Rails.root}/app/assets/data/last_names.csv").split("\n") +
          Person.pluck("last_name") + Person.pluck("mother_last_name") + Person.pluck("father_last_name")).uniq.sort
    end

    names = names.delete_if{|name| name if !name.match(/^#{params[:search_value]}/i)}
    names = names.collect{|n| n.titleize}.sort
    render json: names[0 .. 20].to_json
  end

  def edit

    @person = Person.find(params[:person_id])

    @first_names = (File.read("#{Rails.root}/app/assets/data/first_names.csv").split("\n") +
        Person.pluck("first_name") + Person.pluck("mother_first_name") + Person.pluck("father_first_name")).uniq.sort
    @middle_names = (File.read("#{Rails.root}/app/assets/data/middle_names.csv").split("\n") +
        Person.pluck("middle_name") + Person.pluck("mother_middle_name") + Person.pluck("father_middle_name")).uniq.sort
    @last_names = (File.read("#{Rails.root}/app/assets/data/last_names.csv").split("\n") +
        Person.pluck("last_name") + Person.pluck("mother_last_name") + Person.pluck("father_last_name")).uniq.sort


    tag_id = LocationTag.where(name: "Country").first.id;
    locations = Location.find_by_sql(
        "SELECT l.country FROM location l INNER JOIN location_tag_map m ON l.location_id = m.location_id  WHERE m.location_tag_id = #{tag_id} ")

    @nationalities = locations.map(&:country)
    @action = '/person/new'
  end

  def view
    @person = Person.find(params[:person_id])
  end

  def show
    @person = Person.find(params[:person_id])
    @record = {
        "Details of Child" => [

            {
                ["First Name", "mandatory"] => "#{@person.first_name rescue nil}",
                "Other Name" => "#{@person.middle_name rescue nil}",
                ["Surname", "mandatory"] => "#{@person.last_name rescue nil}"
            },
            {
                ["Date of birth", "mandatory"] => "#{@person.date_of_birth.to_date.strftime('%d/%b/%Y') rescue nil}",
                ["Sex", "mandatory"] => "#{@person.gender}",
                "ID Number" => "#{@person.child_id_number}"
            },
            {
                "Place of birth" => "#{@person.place_of_birth}",
                "Name of Hospital" => "#{@person.hospital_of_birth}",
                "Other Details" => "#{@person.other_place_of_birth_details}"
            },
            {
                "Birth Village" => "#{@person.village_of_birth}",
                "Birth TA" => "#{@person.ta_of_birth}",
                "Birth District" => "#{@person.district_of_birth}"
            },
            {
                "Birth Weight(Kg)" => "#{@person.birth_weight}",
                "Type of birth" => "#{@person.type_of_birth}",
                "Other birth specified" => "#{@person.type_of_birth}"
            },
            {
                "Are the parents married to each other?" => "#{@person.parents_married}",
                "If yes, date of marriage" => "#{@person.date_of_marriage.to_date.strftime('%d/%b/%Y') rescue ""}"
            },
            {
                "Court order attached?" => "#{@person.court_order_attached}",
                "Parents signed" => "#{@person.parents_signed}"
            }
        ],
        "Details of Child's Mother" => [
            {
                ["First Name", "mandatory"] => "#{@person.mother_first_name}",
                "Other Name" => "#{@person.mother_middle_name }",
                ["Maiden Surname", "mandatory"] => "#{@person.mother_last_name}"
            },
            {
                "Date of birth" => "#{@person.mother_date_of_birth}",
                "Nationality" => "#{@person.mother_nationality}",
                "ID Number" => "#{@person.mother_id_number}"
            },
            {
                "Physical Residential Address, District" => "#{@person.mother_residential_district}", 
                "T/A" => "#{@person.mother_residential_ta}",
                "Village" => "#{@person.mother_residential_village}"
            },
            {
                "Home Address, District" => "#{@person.mother_home_district}", 
                "T/A" => "#{@person.mother_home_ta}",
                "Village" => "#{@person.mother_home_village}"
            },
            {
                "Gestation age in weeks" => "#{@person.gestation_at_birth}", 
                "Number of prenatal visits" => "#{@person.number_of_prenatal_visits}",
                "Month of pregnancy prenatal care started" => "#{@person.month_prenatal_care_started}"
            },
            {
                "Mode of delivery" => "#{@person.mode_of_delivery}", 
                "Number of children born to the mother, including this child" => "#{@person.number_of_children_born_alive_inclusive}",
                "Number of children born to the mother, and still living" => "#{@person.number_of_children_born_still_alive}"
            },
            {
                "Level of education" => "#{@person.level_of_education}"
            }
        ],
        "Details of Child's Father" => [
            {
                "First Name" => "#{@person.father_first_name}",
                "Other Name" => "#{@person.father_middle_name}",
                "Surname" => "#{@person.father_last_name}"
            },
            {
                "Date of birth" => "#{@person.father_date_of_birth}",
                "Nationality" => "#{@person.father_nationality}",
                "ID Number" => "#{@person.father_id_number}"
            },
            {
                "Physical Residential Address, District" => "#{@person.father_residential_district}", 
                "T/A" => "#{@person.father_residential_ta}",
                "Village" => "#{@person.father_residential_village}"
            },
            {
                "Home Address, District" => "#{@person.father_home_district}", 
                "T/A" => "#{@person.father_home_ta}",
                "Village" => "#{@person.father_home_village}"
            }
        ],
        "Details of Child's Informant" => [
            {
                "First Name" => "#{@person.informant_first_name}",
                "Other Name" => "#{@person.informant_middle_name}",
                "Surname" => "#{@person.informant_last_name}"
            },
            {
                "Relationship to child" => "#{@person.informant_relationship}",
                "ID Number" => "#{@person.informant_id_number}"
            },
            {
                "Physical Address, District" => "#{@person.informant_district}",
                "T/A" => "#{@person.informant_ta}",
                "Village/Town" => "#{@person.informant_village}"
            },
            {
                "Postal Address" => "#{@person.informant_address_line1}",
                "" => "#{@person.informant_address_line2}",
                "City" => "#{@person.informant_address_line3}"
            },
            {
                "Phone Number" =>"#{@person.informant_phone_number}",
                "Form Signed?" => "#{(@person.form_signed)}"
            },
            {
                "Date of Reporting" => "#{@person.date_reported.to_date.strftime('%d/%b/%Y') rescue ""}"
            }
        ],

        "Details of Village Headman" => [
            {
                "Village Headman Name" => "#{@person.village_headman_name}",
                "Village Headman Signed?" => "#{@person.village_headman_signed}"
            },
            {
                "Name of District" => "#{@person.district_created_at}",
                "Name of TA" => "#{@person.ta_created_at}",
                "Name of Village" => "#{@person.location_created_at}"
            }
        ]
    }
  end

  def dump_data
    File.open("#{Rails.root}/dump.csv", "w"){|f|
      f.write("")
    }

    if Person.dump(params[:location])
      #Send file to server
      data = {data: File.read("#{Rails.root}/dump.csv")}
      link = "#{params[:link]}/offload"
      #RestClient.post(link, data.to_json, :content_type => 'application/json')
      RestClient::Request.execute(:method => :post, :url => link, :timeout => 90000000,
                      :payload => data.to_json,
                      :headers => {:content_type => 'application/json'})

      render :text => "OK"
    else
      render :text => "FAILED"
    end

  end

  def offload_rollback
    if Person.offload_rollback
      render :text => "OK"
    else
      render :text => "FAILED"
    end
  end

  def get_ta_complete
    district_name = params[:district]
    nationality_tag = LocationTag.where(name: 'Traditional Authority').first
    location_id_for_district = Location.where(name: district_name).first.id

    data = [['', '']]
    Location.where("LENGTH(name) > 0 AND name LIKE (?) AND m.location_tag_id = ? AND parent_location = ?",
                   "#{params[:search]}%", nationality_tag.id, location_id_for_district).joins("INNER JOIN location_tag_map m
      ON location.location_id = m.location_id").order('name ASC').map do |l|
      data << [l.id, l.name]
    end

    render json: data.to_json
  end

  def get_village_complete
    district_name = params[:district]
    location_id_for_district = Location.where(name: district_name).first.id

    ta_name = params[:ta]
    location_id_for_ta = Location.where("name = ? AND parent_location = ?",
                                        ta_name, location_id_for_district).first.id


    nationality_tag = LocationTag.where(name: 'Village').first
    data = [['', '']]
    Location.where("LENGTH(name) > 0 AND name LIKE (?) AND m.location_tag_id = ?
      AND parent_location = ?", "#{params[:search]}%", nationality_tag.id,
                   location_id_for_ta).joins("INNER JOIN location_tag_map m
      ON location.location_id = m.location_id").order('name ASC').map do |l|
      data << [l.id, l.name]
    end

    render json: data.to_json
  end

  def get_hospital_complete
    map =  {'Mzuzu City' => 'Mzimba',
            'Lilongwe City' => 'Lilongwe',
            'Zomba City' => 'Zomba',
            'Blantyre City' => 'Blantyre'}

    if  (params[:district].match(/City$/) rescue false)
      params[:district] =map[params[:district]]
    end

    nationality_tag = LocationTag.where("name = 'Hospital' OR name = 'Health Facility'").first
    data = [['', '']]
    parent_location = Location.where(" name = '#{params[:district]}' AND COALESCE(code, '') != '' ").first.id rescue nil

    Location.where("LENGTH(name) > 0 AND name LIKE (?) AND parent_location = #{parent_location} AND m.location_tag_id = ?",
                   "#{params[:search]}%", nationality_tag.id).joins("INNER JOIN location_tag_map m
    ON location.location_id = m.location_id").order('name ASC').map do |l|
      data << [l.id, l.name]
    end

    render json: data
  end

  def set_details_to_temp_session(user, params)
    session[:temp_person_details] = {
        date_of_birth: params[:date_of_birth].to_date.to_s(:db),
        child_id_number: params[:child_id_number],
        place_of_birth: params[:place_of_birth],
        district_of_birth: params[:district_of_birth],
        ta_of_birth: params[:ta_of_birth],
        village_of_birth: params[:village_of_birth],
        hospital_of_birth: params[:hospital_of_birth],
        other_place_of_birth_details: params[:other_birth_place],
        birth_weight: params[:birth_weight],
        type_of_birth: params[:type_of_birth],
        parents_married: params[:parents_married],
        mother_first_name: params[:mother_first_name],
        mother_middle_name: params[:mother_middle_name],
        mother_last_name: params[:mother_last_name],
        mother_nationality: params[:mother_nationality],
        mother_id_number: params[:mother_id_number],
        mother_date_of_birth: params[:mother_date_of_birth],
        mother_residential_country: params[:mother_country],
        mother_residential_district: params[:mother_physical_district],
        mother_residential_ta: params[:mother_physical_ta],
        mother_residential_village: params[:mother_physical_village],
        mother_home_country: params[:mother_country],
        mother_home_district: params[:mother_home_district],
        mother_home_ta: params[:mother_home_ta],
        mother_home_village: params[:mother_home_village],
        date_of_marriage: params[:date_of_marriage],
        court_order_attached: params[:court_order],
        parents_signed: params[:parents_signed],
        gestation_at_birth: params[:gestation_age],
        number_of_prenatal_visits: params[:prenatal_visits_number],
        month_prenatal_care_started: params[:prenatal_care_began],
        mode_of_delivery: params[:delivery_mode],
        number_of_children_born_alive_inclusive: params[:born_alive_number],
        number_of_children_born_still_alive: params[:born_alive_number_living],
        level_of_education: params[:level_of_education],
        father_first_name: params[:father_first_name],
        father_last_name: params[:father_last_name],
        father_middle_name: params[:father_middle_name],
        father_nationality: params[:father_nationality],
        father_id_number: params[:father_id_number],
        father_date_of_birth: params[:father_date_of_birth],
        father_residential_country: params[:father_country],
        father_residential_district: params[:father_physical_district],
        father_residential_ta: params[:father_physical_ta],
        father_residential_village: params[:father_physical_village],
        father_home_country: params[:father_country],
        father_home_district: params[:father_home_district],
        father_home_ta: params[:father_home_ta],
        father_home_village: params[:father_home_village],
        informant_first_name: params[:informant_first_name],
        informant_middle_name: params[:informant_middle_name],
        informant_last_name: params[:informant_last_name],
        informant_nationality: params[:informant_nationality],
        informant_id_number: params[:informant_id_number],
        informant_district: params[:informant_district],
        informant_ta: params[:informant_ta],
        informant_village: params[:informant_village],
        informant_address_line1: params[:informant_address_line1],
        informant_address_line2: params[:informant_address_line2],
        informant_address_line3: params[:informant_address_line3],
        informant_phone_number: params[:informant_phone_number],
        informant_relationship: params[:informant_relationship],
        form_signed: params[:form_signed],
        date_reported: params[:date_reported],
        village_headman_name: params[:village_headman_name],
        village_headman_signed: params[:village_headman_signed],
        ta_created_at: (@cur_location['ta']? @cur_location['ta'] : params[:village_headman_ta])
    }
  end

=begin
  def set_common_details(user, person, params)
    person.place_of_birth     = params[:place_of_birth]
    person.district_of_birth  = params[:district_of_birth]
    person.ta_of_birth        = params[:ta_of_birth]
    person.village_of_birth   = params[:village_of_birth]
    person.hospital_of_birth  = params[:hospital_of_birth]
    person.other_place_of_birth_details = params[:other_birth_place]

    person.birth_weight       = params[:birth_weight]
    person.type_of_birth      = params[:type_of_birth]


    person.parents_married    = params[:parents_married]
    person.mother_first_name  = params[:mother_first_name].titleize rescue nil
    person.mother_middle_name = params[:mother_middle_name].titleize rescue nil
    person.mother_last_name   = params[:mother_last_name].titleize rescue nil
    person.mother_nationality = params[:mother_nationality]
    person.mother_id_number   = params[:mother_id_number].to_s.upcase
    person.date_of_marriage   = params[:date_of_marriage]

    person.court_order_attached = params[:court_order]
    person.parents_signed     = params[:parents_signed]

    person.father_first_name  = params[:father_first_name].titleize rescue nil
    person.father_last_name   = params[:father_last_name].titleize rescue nil
    person.father_middle_name = params[:father_middle_name].titleize rescue nil
    person.father_nationality = params[:father_nationality]
    person.father_id_number   = params[:father_id_number].to_s.upcase

    person.informant_first_name  = params[:informant_first_name].titleize rescue nil
    person.informant_middle_name = params[:informant_middle_name].titleize rescue nil
    person.informant_last_name   = params[:informant_last_name].titleize rescue nil
    person.informant_nationality = params[:informant_nationality]
    person.informant_id_number   = params[:informant_id_number].to_s.upcase

    person.informant_district    = params[:informant_district]
    person.informant_ta          = params[:informant_ta]
    person.informant_village     = params[:informant_village]

    person.informant_address_line1 = params[:informant_address_line1]
    person.informant_address_line2 = params[:informant_address_line2]
    person.informant_address_line3 = params[:informant_address_line3]
    person.informant_phone_number  = params[:informant_phone_number]
    person.informant_relationship  = params[:informant_relationship]

    person.form_signed             = params[:form_signed]
    person.date_reported           = params[:date_reported]

    person.village_headman_name    = params[:village_headman_name]
    #person.village_senior_name     = params[:village_senior_name]
    person.village_headman_signed  = params[:village_headman_signed]

    person.district_created_at     = @cur_location['district']
    person.ta_created_at           = (params[:ta_name].blank? ? @cur_location['ta'] : params[:ta_name])
    case @cur_location['type']
    when "DRO"
      person.location_created_at = @cur_location['district']
    when "Village"
      person.location_created_at = @cur_location['village']
    when "Health Facility"
      person.location_created_at  = @cur_location['health_facility']
    end

    person.upload_status           = "NOT UPLOADED"
    person.creator                 = "#{user.id}|#{user.username}|#{user.first_name} #{user.middle_name} #{user.last_name}"

  end
=end

  def get_temp_details(person)

    person.date_of_birth = session[:temp_person_details]['date_of_birth']
    person.child_id_number = session[:temp_person_details]['child_id_number']
    person.place_of_birth = session[:temp_person_details]['place_of_birth']
    person.district_of_birth = session[:temp_person_details]['district_of_birth']
    person.ta_of_birth = session[:temp_person_details]['ta_of_birth']
    person.village_of_birth = session[:temp_person_details]['village_of_birth']
    person.hospital_of_birth = session[:temp_person_details]['hospital_of_birth']
    person.other_place_of_birth_details = session[:temp_person_details]['other_place_of_birth_details']
    person.birth_weight = session[:temp_person_details]['birth_weight']
    person.type_of_birth = session[:temp_person_details]['type_of_birth']
    person.parents_married = session[:temp_person_details]['parents_married']
    person.mother_first_name = session[:temp_person_details]['mother_first_name']
    person.mother_middle_name = session[:temp_person_details]['mother_middle_name']
    person.mother_last_name = session[:temp_person_details]['mother_last_name']
    person.mother_nationality = session[:temp_person_details]['mother_nationality']
    person.mother_id_number = session[:temp_person_details]['mother_id_number']
    person.mother_date_of_birth = session[:temp_person_details]['mother_date_of_birth']
    person.mother_residential_country = session[:temp_person_details]['mother_residential_country']
    person.mother_residential_district = session[:temp_person_details]['mother_residential_district']
    person.mother_residential_ta = session[:temp_person_details]['mother_residential_ta']
    person.mother_residential_village = session[:temp_person_details]['mother_residential_village']
    person.mother_home_country = session[:temp_person_details]['mother_home_country']
    person.mother_home_district = session[:temp_person_details]['mother_home_district']
    person.mother_home_ta = session[:temp_person_details]['mother_home_ta']
    person.mother_home_village = session[:temp_person_details]['mother_home_village']
    person.date_of_marriage = session[:temp_person_details]['date_of_marriage']
    person.court_order_attached = session[:temp_person_details]['court_order_attached']
    person.parents_signed = session[:temp_person_details]['parents_signed']
    person.gestation_at_birth = session[:temp_person_details]['gestation_at_birth']
    person.number_of_prenatal_visits = session[:temp_person_details]['number_of_prenatal_visits']
    person.month_prenatal_care_started = session[:temp_person_details]['month_prenatal_care_started']
    person.mode_of_delivery = session[:temp_person_details]['mode_of_delivery']
    person.number_of_children_born_alive_inclusive = session[:temp_person_details]['number_of_children_born_alive_inclusive']
    person.number_of_children_born_still_alive = session[:temp_person_details]['number_of_children_born_still_alive']
    person.level_of_education = session[:temp_person_details]['level_of_education']
    person.father_first_name = session[:temp_person_details]['father_first_name']
    person.father_last_name = session[:temp_person_details]['father_last_name']
    person.father_middle_name = session[:temp_person_details]['father_middle_name']
    person.father_nationality = session[:temp_person_details]['father_nationality']
    person.father_id_number = session[:temp_person_details]['father_id_number']
    person.father_date_of_birth = session[:temp_person_details]['father_date_of_birth']
    person.father_residential_country = session[:temp_person_details]['father_residential_country']
    person.father_residential_district = session[:temp_person_details]['father_residential_district']
    person.father_residential_ta = session[:temp_person_details]['father_residential_ta']
    person.father_residential_village = session[:temp_person_details]['father_residential_village']
    person.father_home_country = session[:temp_person_details]['father_home_country']
    person.father_home_district = session[:temp_person_details]['father_home_district']
    person.father_home_ta = session[:temp_person_details]['father_home_ta']
    person.father_home_village = session[:temp_person_details]['father_home_village']
    person.informant_first_name = session[:temp_person_details]['informant_first_name']
    person.informant_middle_name = session[:temp_person_details]['informant_middle_name']
    person.informant_last_name = session[:temp_person_details]['informant_last_name']
    person.informant_nationality = session[:temp_person_details]['informant_nationality']
    person.informant_id_number = session[:temp_person_details]['informant_id_number']
    person.informant_district = session[:temp_person_details]['informant_district']
    person.informant_ta = session[:temp_person_details]['informant_ta']
    person.informant_village = session[:temp_person_details]['informant_village']
    person.informant_address_line1 = session[:temp_person_details]['informant_address_line1']
    person.informant_address_line2 = session[:temp_person_details]['informant_address_line2']
    person.informant_address_line3 = session[:temp_person_details]['informant_address_line3']
    person.informant_phone_number = session[:temp_person_details]['informant_phone_number']
    person.informant_relationship = session[:temp_person_details]['informant_relationship']
    person.form_signed = session[:temp_person_details]['form_signed']
    person.date_reported = session[:temp_person_details]['date_reported']
    person.village_headman_name = session[:temp_person_details]['village_headman_name']
    person.village_headman_signed = session[:temp_person_details]['village_headman_signed']
    person.ta_created_at = session[:temp_person_details]['ta_created_at']

    person
  end

  def delete_multiple_workflow
    session.delete(:multiple_births)
    session.delete(:multiple_births_value)
    session.delete(:number_of_child)
    session.delete(:temp_person_details)
  end

  def save_record

    user = User.find(session[:user_id])

    person = Person.find(params[:person_id]) rescue nil #editing record
    person = Person.new if person.blank?                #new record

    person.birth_registration_type = params[:registration_type]

    person.first_name         = params[:first_name].titleize rescue nil
    person.last_name          = params[:last_name].titleize rescue nil
    person.middle_name        = params[:middle_name].titleize rescue nil

    person.gender             = params[:gender]

    if session[:temp_person_details]
      get_temp_details(person)
    else
      person.date_of_birth      = params[:date_of_birth].to_date.to_s(:db)
      person.child_id_number    = params[:child_id_number]

      person.place_of_birth     = params[:place_of_birth]
      person.district_of_birth  = params[:district_of_birth]
      person.ta_of_birth        = params[:ta_of_birth]
      person.village_of_birth   = params[:village_of_birth]
      person.hospital_of_birth  = params[:hospital_of_birth]
      person.other_place_of_birth_details = params[:other_birth_place]

      person.birth_weight       = params[:birth_weight]
      person.type_of_birth      = params[:type_of_birth]

      person.parents_married    = params[:parents_married]
      person.date_of_marriage   = params[:date_of_marriage]
      person.court_order_attached = params[:court_order]
      person.parents_signed     = params[:parents_signed]

      person.mother_first_name  = params[:mother_first_name].titleize rescue nil
      person.mother_middle_name = params[:mother_middle_name].titleize rescue nil
      person.mother_last_name   = params[:mother_last_name].titleize rescue nil
      person.mother_date_of_birth = params[:mother_date_of_birth]
      person.mother_nationality = params[:mother_nationality]
      person.mother_id_number   = params[:mother_id_number].to_s.upcase
      person.mother_residential_country = params[:mother_country]
      person.mother_residential_district = params[:mother_physical_district]
      person.mother_residential_ta = params[:mother_physical_ta]
      person.mother_residential_village = params[:mother_physical_village]
      person.mother_home_country = params[:mother_country]
      person.mother_home_district = params[:mother_home_district]
      person.mother_home_ta = params[:mother_home_ta]
      person.mother_home_village = params[:mother_home_village]

      person.gestation_at_birth = params[:gestation_age]
      person.number_of_prenatal_visits = params[:prenatal_visits_number]
      person.month_prenatal_care_started = params[:prenatal_care_began]
      person.mode_of_delivery = params[:delivery_mode]
      person.number_of_children_born_alive_inclusive = params[:born_alive_number]
      person.number_of_children_born_still_alive = params[:born_alive_number_living]
      person.level_of_education = params[:level_of_education]

      person.father_first_name  = params[:father_first_name].titleize rescue nil
      person.father_last_name   = params[:father_last_name].titleize rescue nil
      person.father_middle_name = params[:father_middle_name].titleize rescue nil
      person.father_date_of_birth = params[:father_date_of_birth]
      person.father_nationality = params[:father_nationality]
      person.father_id_number   = params[:father_id_number].to_s.upcase

      person.father_residential_country = params[:father_country]
      person.father_residential_district = params[:father_physical_district]
      person.father_residential_ta = params[:father_physical_ta]
      person.father_residential_village = params[:father_physical_village]
      person.father_home_country = params[:father_country]
      person.father_home_district = params[:father_home_district]
      person.father_home_ta = params[:father_home_ta]
      person.father_home_village = params[:father_home_village]

      person.informant_first_name  = params[:informant_first_name].titleize rescue nil
      person.informant_middle_name = params[:informant_middle_name].titleize rescue nil
      person.informant_last_name   = params[:informant_last_name].titleize rescue nil
      person.informant_nationality = params[:informant_nationality]
      person.informant_id_number   = params[:informant_id_number].to_s.upcase

      person.informant_district    = params[:informant_district]
      person.informant_ta          = params[:informant_ta]
      person.informant_village     = params[:informant_village]

      person.informant_address_line1 = params[:informant_address_line1]
      person.informant_address_line2 = params[:informant_address_line2]
      person.informant_address_line3 = params[:informant_address_line3]
      person.informant_phone_number  = params[:informant_phone_number]
      person.informant_relationship  = params[:informant_relationship]

      person.form_signed             = params[:form_signed]
      person.date_reported           = params[:date_reported]

      person.village_headman_name    = params[:village_headman_name]
      person.village_senior_name     = params[:senior_member_name]
      person.village_headman_signed  = params[:village_headman_signed]
      person.ta_created_at           = (@cur_location['ta']? @cur_location['ta'] : params[:village_headman_ta])
    end

    person.district_created_at     = @cur_location['district']

    case @cur_location['type']
    when "DRO"
      person.location_created_at = @cur_location['district']
    when "Village"
      person.location_created_at = @cur_location['village']
    when "Health Facility"
      person.location_created_at  = @cur_location['health_facility']
    else
      # type code here
    end

    person.upload_status           = "NOT UPLOADED"
    person.creator                 = "#{user.id}|#{user.username}|#{user.first_name} #{user.middle_name} #{user.last_name}"
    person.created_at              = DateTime.now if person.created_at.blank?
    person.updated_at              = DateTime.now
    person.save

    if params[:type_of_birth] != 'Single'

      unless session[:temp_person_details]
        set_details_to_temp_session(user, params)
      end

      session[:multiple_births] = true
      session[:number_of_child] = 2

      case params[:type_of_birth]
      when 'Twin'
        session[:multiple_births_value] = 2
      when 'Triplet'
        session[:multiple_births_value] = 3
      when 'Other'
        session[:multiple_births_value] = params[:specify_type_of_birth]
      else
        delete_multiple_workflow
      end

      number_of_child = session[:number_of_child].to_i
      multiple_births_value = session[:multiple_births_value].to_i

      if number_of_child <= multiple_births_value
        session[:number_of_child] = number_of_child + 1
        render :plain => "Redirect" and return
      else
        delete_multiple_workflow
      end

    end

    render plain: "OK"
  end

  def offload
    search_val = params[:search][:value] rescue nil
    search_val = '_' if search_val.blank?

    cur_location = JSON.parse(File.read("#{Rails.root}/public/current.json")) rescue {}
    if !params[:start].blank?

      d = Person.order(" person.created_at DESC, person.village_of_birth, person.ta_of_birth, person.district_of_birth, person.first_name ")
        .where(" person.upload_status = 'NOT UPLOADED' AND concat_ws('_', person.first_name, person.last_name, person.middle_name,
                          person.district_of_birth, person.ta_of_birth, person.village_of_birth,
                          person.mother_first_name, person.mother_middle_name, person.mother_last_name,
                          person.father_first_name, person.father_middle_name, person.father_last_name,
                          DATE_FORMAT(person.date_of_birth, '%d/%b/%Y'), person.gender) REGEXP \"#{search_val}\" ")

        total = d.select(" count(*) c ")[0]['c'] rescue 0
        page = (params[:start].to_i / params[:length].to_i) + 1

        data = d.group(" person.person_id ")
        data = data.page(page)
        .per_page(params[:length].to_i)

        @records = []
        data.each do |p|
          next if p.upload_status == "UPLOADED"
          next if p.district_created_at != cur_location['district']
          arr = [p.name,
                 p.date_of_birth.to_date.strftime('%d/%b/%Y'),
                 p.gender,
                 p.place_of_birth,
                 p.mother_name,
                 p.father_name,
                 p.upload_status,
                 p.person_id
          ]

        @records << arr
      end

      render json: {
          "draw" => params[:draw].to_i,
          "recordsTotal" => total,
          "recordsFiltered" => total,
          "data" => @records}.to_json and return
    end

    # @records = PersonService.query_for_display(@states)

    render :template => "/person/offload"
  end
  def ebrs_connect
    render json: {:remote_tocken => "HHHHHHHH"}.to_json
  end

  def remote_format
      #Mothers birthdate and Fathers birthdate
      person = Person.find(params[:id])
      render json: person.to_json
  end

  def update_upload_status

    person = Person.find(params[:id])
    person.upload_status ="UPLOADED"
    person.upload_datetime = Time.now
    person.save
    render json: {:person_id => params[:id], :status => "UPLOADED"}.to_json
  end
end