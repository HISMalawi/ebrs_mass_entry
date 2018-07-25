class HomeController < ApplicationController
  def index

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

    @data2 = []
    Person.find_by_sql(" SELECT DISTINCT(ta_of_birth) AS ta FROM person ").map(&:ta).each do |ta|
      dt = {'ta' => ta}
      dt['offloaded'] = Person.where(ta_of_birth: ta, upload_status: 'UPLOADED').count
      dt['not_offloaded'] = Person.where(ta_of_birth: ta, upload_status: 'NOT UPLOADED').count

      @data2 << dt
    end

    @all2 = {
        'offloaded'     => @data2.collect{|dt| dt['offloaded']}.sum,
        'not_offloaded' => @data2.collect{|dt| dt['not_offloaded']}.sum
    }
  end
end
