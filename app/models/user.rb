class User < ApplicationRecord
  self.table_name = :user
  self.primary_key = :user_id

  def password_matches?(plain_password)
    !plain_password.blank? and BCrypt::Password.new(self.password) == plain_password
  end

  def name
    "#{self.first_name} #{self.middle_name} #{self.last_name}".gsub(/\s+/, ' ')
  end

  def sex
    {0 => 'Female', 1 => 'Male'}[self.gender]
  end

  def role
    user_role = UserRole.where(user_id: self.id).last
    role = Role.where(role_id: user_role.role_id).last
    role.name
  end
end
