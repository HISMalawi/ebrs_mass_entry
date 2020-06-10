class HomeController < ApplicationController
  def index

    @data = []
    Person.find_by_sql(" SELECT DISTINCT(location_created_at) AS village FROM person ").map(&:village).each do |vg|
      dt = {'village' => vg}
      dt['offloaded'] = Person.where(location_created_at: vg, upload_status: 'UPLOADED').count
      dt['not_offloaded'] = Person.where(location_created_at: vg, upload_status: 'NOT UPLOADED').count

      @data << dt
    end

    @all = {
        'offloaded'     => @data.collect{|dt| dt['offloaded']}.sum,
        'not_offloaded' => @data.collect{|dt| dt['not_offloaded']}.sum
    }

    @data2 = []
    Person.find_by_sql(" SELECT DISTINCT(ta_created_at) AS ta FROM person ").map(&:ta).each do |ta|
      dt = {'ta' => ta}
      dt['offloaded'] = Person.where(ta_created_at: ta, upload_status: 'UPLOADED').count
      dt['not_offloaded'] = Person.where(ta_created_at: ta, upload_status: 'NOT UPLOADED').count

      @data2 << dt
    end

    @all2 = {
        'offloaded'     => @data2.collect{|dt| dt['offloaded']}.sum,
        'not_offloaded' => @data2.collect{|dt| dt['not_offloaded']}.sum
    }
  end
end
