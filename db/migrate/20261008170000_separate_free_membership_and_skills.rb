class SeparateFreeMembershipAndSkills < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :skills_access_until, :date
    # Preserve paid access previously represented by a current membership.
    execute <<~SQL
      UPDATE users SET skills_access_until = memberships.ends_on
      FROM memberships WHERE memberships.user_id = users.id
      AND memberships.status = 'active' AND memberships.starts_on <= CURRENT_DATE
      AND memberships.ends_on >= CURRENT_DATE;
      UPDATE memberships SET starts_on = LEAST(starts_on, CURRENT_DATE), ends_on = '9999-12-31', status = 'active';
      INSERT INTO memberships (user_id, starts_on, ends_on, status, created_at, updated_at)
      SELECT id, CURRENT_DATE, '9999-12-31', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM users WHERE NOT EXISTS (SELECT 1 FROM memberships WHERE memberships.user_id = users.id);
    SQL
  end
  def down
    raise ActiveRecord::IrreversibleMigration, "Les adhésions gratuites ne permettent pas de reconstruire les anciennes périodes."
  end
end
