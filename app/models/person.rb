class Person < ActiveRecord::Base
  self.table_name = :person
  self.primary_key = :person_id

  def name
    "#{self.first_name} #{self.middle_name} #{self.last_name}".gsub(/\s+/, " ")
  end

  def mother_name
    "#{self.mother_first_name} #{self.mother_middle_name} #{self.mother_last_name}".gsub(/\s+/, " ")
  end

  def father_name
    "#{self.father_first_name} #{self.father_middle_name} #{self.father_last_name}".gsub(/\s+/, " ")
  end

  def informant_name
    "#{self.informant_first_name} #{self.informant_middle_name} #{self.informant_last_name}".gsub(/\s+/, " ")
  end

  def place_of_birth
    "#{self.village_of_birth}, #{self.ta_of_birth}, #{self.district_of_birth}".gsub(/\s+/, " ")
  end
end
