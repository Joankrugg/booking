class CreateModernBoxCore < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.string :status, null: false, default: "active"
      t.timestamps
    end
    create_table :groups do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.string :genre
      t.text :description
      t.string :city
      t.integer :member_count
      t.string :contact_email, null: false
      t.string :contact_phone
      t.string :instagram_url
      t.string :youtube_url
      t.string :tiktok_url
      t.boolean :published, null: false, default: false
      t.timestamps
    end
    create_table :group_managers do |t|
      t.references :group, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    add_index :group_managers, [ :group_id, :user_id ], unique: true
    create_table :concert_availabilities do |t|
      t.references :group, null: false, foreign_key: true
      t.references :confirmed_by, null: false, foreign_key: { to_table: :users }
      t.date :date, null: false
      t.string :status, null: false, default: "available"
      t.string :area_name, null: false
      t.string :area_key, null: false
      t.text :public_note
      t.datetime :confirmed_at, null: false
      t.timestamps
    end
    add_index :concert_availabilities, [ :group_id, :date, :area_key ], unique: true, name: "idx_concert_area_unique"
    add_index :concert_availabilities, [ :date, :area_key, :status ], name: "idx_concert_search"
    create_table :skills do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.string :compatibility, null: false
      t.boolean :published, null: false, default: false
      t.timestamps
    end
    create_table :skill_releases do |t|
      t.references :skill, null: false, foreign_key: true
      t.string :version, null: false
      t.text :instructions, null: false
      t.text :changelog
      t.timestamps
    end
    add_index :skill_releases, [ :skill_id, :version ], unique: true
  end
end
