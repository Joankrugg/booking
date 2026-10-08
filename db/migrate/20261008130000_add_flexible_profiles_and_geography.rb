class AddFlexibleProfilesAndGeography < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :uses_groups, :boolean, default: false, null: false
    add_column :users, :uses_organizing, :boolean, default: false, null: false
    add_column :users, :uses_concerts, :boolean, default: false, null: false
    execute "UPDATE users SET uses_groups = TRUE WHERE profile_type = 'artist'"
    execute "UPDATE users SET uses_organizing = TRUE WHERE profile_type = 'organizer'"
    execute "UPDATE users SET uses_concerts = TRUE WHERE profile_type = 'audience'"
    [:concerts, :concert_availabilities].each do |table|
      add_column table, :latitude, :float
      add_column table, :longitude, :float
      add_index table, [:latitude, :longitude]
    end
    add_column :concert_availabilities, :travel_radius_km, :integer, default: 50, null: false
    # Old named zones have no declared radius: do not invent one on upgrade.
    execute "UPDATE concert_availabilities SET travel_radius_km = 0"
    add_column :concert_availabilities, :starts_at_time, :time
    add_column :concert_availabilities, :ends_at_time, :time
    create_table :geocoded_places do |t|
      t.string :query_key, null: false
      t.string :label
      t.float :latitude
      t.float :longitude
      t.datetime :looked_up_at
      t.timestamps
    end
    add_index :geocoded_places, :query_key, unique: true
    create_table :geocoding_gates do |t|
      t.datetime :requested_at
    end
    execute "INSERT INTO geocoding_gates (id) VALUES (1)"
  end
  def down
    drop_table :geocoding_gates
    drop_table :geocoded_places
    [:concerts, :concert_availabilities].each do |table|
      remove_column table, :latitude
      remove_column table, :longitude
    end
    [:travel_radius_km, :starts_at_time, :ends_at_time].each { |column| remove_column :concert_availabilities, column }
    [:uses_groups, :uses_organizing, :uses_concerts].each { |column| remove_column :users, column }
  end
end
