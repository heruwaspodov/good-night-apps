# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create seed users
user_names = [
  'Alice Johnson',
  'Bob Smith',
  'Carol Williams',
  'David Brown',
  'Emma Davis',
  'Frank Miller',
  'Grace Wilson',
  'Henry Moore',
  'Ivy Taylor',
  'Jack Anderson'
]

puts "Creating seed users..."
user_names.each do |name|
  User.find_or_create_by!(name: name) do |user|
    puts "Created user: #{name}"
  end
end

puts "Seed users created successfully!"
