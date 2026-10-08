class AddProfilesAndConcerts < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :profile_type, :string, null: false, default: "artist"
    add_column :users, :organizer_type, :string
    add_column :users, :organization_name, :string
    add_column :users, :profile_details, :text
    create_table :concerts do |t|
      t.references :group, null: false, foreign_key: true
      t.string :title, null: false
      t.datetime :starts_at, null: false
      t.string :venue_name, null: false
      t.string :city, null: false
      t.string :city_key, null: false
      t.string :address
      t.text :description
      t.string :ticket_url
      t.boolean :published, null: false, default: false
      t.boolean :cancelled, null: false, default: false
      t.timestamps
    end
    add_index :concerts, [:starts_at, :city_key, :published]
  end
end
