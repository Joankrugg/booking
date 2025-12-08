user = User.first || User.create!(email: "test@test.com", password: "password")

type = ServiceType.first || ServiceType.create!(name: "fixed")

service = Service.create!(
  user: user,
  name: "Prestation initiale",
  description: "Service de test",
  price_euros: 80,
  duration_minutes: 60,
  service_type: type
)

service.availability_rules.create!(
  weekday: 1,
  start_time: "10:00",
  end_time: "18:00"
)
