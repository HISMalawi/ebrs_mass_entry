class PersonController < ApplicationController
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

      render :text => {
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
    render :text => names[0 .. 20].to_json
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

  def save_record
    user = User.find(session[:user_id])

    person = Person.find(params[:person_id]) rescue nil #editing record
    person = Person.new if person.blank?                #new record

    person.first_name         = params[:first_name].titleize rescue nil
    person.last_name          = params[:last_name].titleize rescue nil
    person.middle_name        = params[:middle_name].titleize rescue nil

    person.gender             = params[:gender]
    person.date_of_birth      = params[:date_of_birth].to_date.to_s(:db)

    person.place_of_birth     = params[:place_of_birth]
    person.district_of_birth  = params[:birth_district]
    person.ta_of_birth        = params[:birth_ta]
    person.village_of_birth   = params[:birth_village]

    person.parents_married    = params[:parents_married]
    person.mother_first_name  = params[:mother_first_name].titleize rescue nil
    person.mother_middle_name = params[:mother_middle_name].titleize rescue nil
    person.mother_last_name   = params[:mother_last_name].titleize rescue nil
    person.mother_nationality = params[:mother_nationality]
    person.mother_id_number   = params[:mother_id_number].to_s.upcase
    person.date_of_marriage   = params[:date_of_marriage]

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
    person.location_created_at     = (params[:village_name].blank? ? @cur_location['village'] : params[:village_name])

    person.upload_status           = "NOT UPLOADED"
    person.creator                 = "#{user.id}|#{user.username}|#{user.first_name} #{user.middle_name} #{user.last_name}"

    person.created_at              = DateTime.now if person.created_at.blank?
    person.updated_at              = DateTime.now
    person.save

    render :text => "OK";
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
            },
            {
                "Birth Village" => "#{@person.village_of_birth}",
                "Birth TA" => "#{@person.ta_of_birth}",
                "Birth District" => "#{@person.district_of_birth}"
            },
            {
                "Are the parents married to each other?" => "#{@person.parents_married}",
                "If yes, date of marriage" => "#{@person.date_of_marriage.to_date.strftime('%d/%b/%Y') rescue ""}"
            }
        ],
        "Details of Child's Mother" => [
            {
                ["First Name", "mandatory"] => "#{@person.mother_first_name}",
                "Other Name" => "#{@person.mother_middle_name }",
                ["Maiden Surname", "mandatory"] => "#{@person.mother_last_name}"
            },
            {
                "Nationality" => "#{@person.mother_nationality}",
                "ID Number" => "#{@person.mother_id_number}"
            }
        ],
        "Details of Child's Father" => [
            {
                "First Name" => "#{@person.father_first_name}",
                "Other Name" => "#{@person.father_middle_name}",
                "Surname" => "#{@person.father_last_name}"
            },
            {
                "Nationality" => "#{@person.father_nationality}",
                "ID Number" => "#{@person.father_id_number}"
            }
        ],
        "Details of Child's Informant" => [
            {
                "First Name" => "#{@person.informant_first_name}",
                "Other Name" => "#{@person.informant_middle_name}",
                "Family Name" => "#{@person.informant_last_name}"
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
end
