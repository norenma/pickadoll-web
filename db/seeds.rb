# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.find_or_initialize_by(email: 'admin@example.com')
user.username = 'admin'
user.password = 'password'
user.create_user_permission = true
user.save!

other_user = User.find_or_initialize_by(email: 'user@example.com')
other_user.username = 'user'
other_user.password = 'password'
other_user.save!
