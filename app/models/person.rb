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

  def self.dump

    data = Person.new.attributes.keys.join(",") + "\n"
    upload_number   = Person.find_by_sql(" SELECT MAX(upload_number) n FROM person ").last['n'].to_i + 1
    upload_datetime = Time.now
    Person.where(upload_status: "NOT UPLOADED").each do |person|
      data = data + person.attributes.values.join(",") + "\n"
      person.upload_status   =  "UPLOADED"
      person.upload_number   = upload_number
      person.upload_datetime = upload_datetime
      person.save
    end

    File.open("#{Rails.root}/dump.csv", "w"){|f|
      f.write(data)
    }

    return true
  end

  def self.offload_rollback
    File.read("#{Rails.root}/dump.csv").split("\n").each{|line|
      data = line.split(",")
      next if data.first.strip == "person_id"

      person                    = Person.find(data[0])
      person.upload_status      = "NOT UPLOADED"
      person.upload_number      = nil
      person.upload_datetime    = nil
      person                    .save
    }

    File.open("#{Rails.root}/dump.csv", "w"){|f|
      f.write("")
    }

    return true
  end
end
