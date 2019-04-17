u = User.where(username: 'admin').first
admin_role = Role.where(name: "administrator").first

user_roles = UserRole.where(user_id: u.id)
if user_roles.length == 0
	UserRole.create(role_id: admin_role.id, user_id: u.id)
	puts "Success!!"
else

	user_roles.each {|ur| 
		ur.role_id = admin_role.id
		ur.save
	}

	puts "Success!!"
end
