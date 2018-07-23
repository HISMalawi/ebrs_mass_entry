class HomeController < ApplicationController
  def index
    @males = Person.where(" gender = 'Male' ").count
    @females = Person.where(" gender = 'Female' ").count
    @all = Person.count
  end
end
