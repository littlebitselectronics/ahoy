class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    create_table :ahoy_events, id: false do |t|
      t.uuid :id, primary_key: true
      t.uuid :visit_id

      # user
      t.integer :user_id
      t.uuid :visitor_id

      t.string :name

      t.timestamps
    end

    add_index :ahoy_events, [:visit_id]
    add_index :ahoy_events, [:user_id]
    add_index :ahoy_events, [:time]
  end
end
