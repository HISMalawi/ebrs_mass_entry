class HomeController < ApplicationController
  def index
    @males = Person.where(" gender = 'Male' ").count
    @females = Person.where(" gender = 'Female' ").count
    @all = Person.count

    @data = []
    Person.find_by_sql(" SELECT DISTINCT(village_of_birth) AS village FROM person ").map(&:village).each do |vg|
      dt = {'village' => vg}
      dt['offloaded'] = Person.where(village_of_birth: vg, upload_status: 'UPLOADED').count
      dt['not_offloaded'] = Person.where(village_of_birth: vg, upload_status: 'NOT UPLOADED').count

      @data << dt
    end

    @all = {
        'offloaded'     => @data.collect{|dt| dt['offloaded']}.sum,
        'not_offloaded' => @data.collect{|dt| dt['not_offloaded']}.sum
    }
  end
end
