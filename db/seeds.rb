# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
u = User.create(
    username: 'admin',
    password: BCrypt::Password.create('p@ssword'),
    first_name: 'EBRS',
    last_name: 'Administrator',
    middle_name: 'Mass',
    gender: "Male",
    designation: 'Software Developer'
)

["Administrator", "Data Clerk", "Data Supervisor"].each {|role|
	Role.create(
		  name: role, description: ''
	)
}

r = Role.where(name: "Administrator").first

UserRole.create(
    user_id: u.id, role_id: r.id
)

begin
  ActiveRecord::Base.transaction do
    require Rails.root.join('db','load_location_tags.rb')
    require Rails.root.join('db','load_countries.rb')
    require Rails.root.join('db','load_districts.rb')
    require Rails.root.join('db','load_tas_and_villages.rb')
    require Rails.root.join('db','load_health_facilities.rb')
    require Rails.root.join('db','load_names.rb')
  end
rescue => e
  puts "Error ::::  #{e.message}  ::  #{e.backtrace.inspect}"
end
