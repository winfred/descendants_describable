require 'active_record'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Migrator.up "db/migrate"

ActiveRecord::Migration.create_table :models do |t|
  t.string :type
  t.integer :actor_id
  t.integer :target_id

  t.timestamps
end
