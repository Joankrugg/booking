#user = User.first || User.create!(email: "test@test.com", password: "password")

#type = ServiceType.first || ServiceType.create!(name: "fixed")

#service = Service.create!(
#  user: user,
 # name: "Prestation initiale",
  #description: "Service de test",
  #price_euros: 80,
  #duration_minutes: 60,
  #service_type: type
#)

#service.availability_rules.create!(
#  weekday: 1,
#  start_time: "10:00",
#  end_time: "18:00"
#)


Category.find_or_create_by!(slug: "relax") do |c|
  c.name = "Se détendre"
end

Category.find_or_create_by!(slug: "move") do |c|
  c.name = "Bouger"
end

Category.find_or_create_by!(slug: "discover") do |c|
  c.name = "Découvrir"
end

Category.find_or_create_by!(slug: "share") do |c|
  c.name = "Partager"
end
