class PersonController < ApplicationController
  def index
    @people = Person.all.order(:person_id).limit(100)
  end

  def new
    if request.post?
    
      redirect_to '/person/index'
    end

    @user = Person.new
    @action = '/person/new'
  end

  def view
    @person = Person.find(params[:person_id])
  end

  def save_record
    user = User.find(session[:user_id])

    person = Person.new

    person.first_name         = params[:first_name]
    person.last_name          = params[:last_name]
    person.middle_name        = params[:middle_name]

    person.gender             = params[:gender]
    person.date_of_birth      = params[:date_of_birth]

    person.place_of_birth     = params[:place_of_birth]
    person.district_of_birth  = params[:birth_district]
    person.ta_of_birth        = params[:birth_ta]
    person.village_of_birth   = params[:birth_village]

    person.parents_married    = params[:parents_married]
    person.mother_first_name  = params[:mother_first_name]
    person.mother_middle_name = params[:mother_middle_name]
    person.mother_last_name   = params[:mother_last_name]
    person.mother_nationality = params[:mother_nationality]
    person.mother_id_number   = params[:mother_id_number]
    person.date_of_marriage   = params[:date_of_marriage]

    person.father_first_name  = params[:father_first_name]
    person.father_last_name   = params[:father_last_name]
    person.father_middle_name = params[:father_middle_name]
    person.father_nationality = params[:father_nationality]
    person.father_id_number   = params[:father_id_number]

    person.informant_first_name  = params[:informant_first_name]
    person.informant_middle_name = params[:informant_middle_name]
    person.informant_last_name   = params[:informant_last_name]
    person.informant_nationality = params[:informant_nationality]
    person.informant_id_number   = params[:informant_id_number]

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

    person.district_created_at     = session[:district] || "N/A"
    person.ta_created_at           = session[:ta] || "N/A"
    person.location_created_at     = session[:location] || "N/A"

    person.upload_status           = "NOT UPLOADED"
    person.creator                 = "#{user.id}|#{user.username}|#{user.first_name} #{user.middle_name} #{user.last_name}"

    person.created_at              = DateTime.now
    person.updated_at              = DateTime.now
    person.save
  end
end
