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
end
