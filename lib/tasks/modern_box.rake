namespace :modern_box do
  desc "Grant administrator access to an existing account (ADMIN_EMAIL required)"
  task admin: :environment do
    email = ENV.fetch("ADMIN_EMAIL").strip.downcase
    User.find_by!(email: email).update!(admin: true)
    puts "Administrator access granted."
  end
  desc "Create draft groups for the three known projects (OWNER_EMAIL required)"
  task drafts: :environment do
    owner = User.find_by!(email: ENV.fetch("OWNER_EMAIL").strip.downcase)
    [["Deftoons", "[Genre à compléter]", 4], ["Schmok", "[Genre à compléter]", 5], ["Vector", "[Genre à compléter]", 2]].each do |name, genre, count|
      owner.owned_groups.find_or_create_by!(name: name) do |group|
        group.genre = genre
        group.member_count = count
        group.description = "[Histoire et présentation à compléter]"
        group.contact_email = ENV.fetch("CONTACT_EMAIL", "modernboxrecords@gmail.com")
        group.contact_phone = "07 60 95 09 56"
        group.published = false
      end
    end
    puts "Draft groups ready; no availability or membership was fabricated."
  end
end
