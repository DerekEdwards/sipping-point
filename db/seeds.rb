# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
users = [
{name: "A-A-Ron", email: "amagil@fake.com"},
{name: "Doctor Captain Derique", email: "derique@fake.com"}
]
users.each do |u|
  User.create(u)
end