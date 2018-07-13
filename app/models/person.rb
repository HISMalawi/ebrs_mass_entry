class Person < ActiveRecord::Base
  self.table_name = :person
  self.primary_key = :person_id
end
