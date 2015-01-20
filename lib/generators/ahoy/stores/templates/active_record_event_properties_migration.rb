class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    create_table :ahoy_event_properties do |t|

      # event
      t.integer :event_id
      t.string :name
      t.string :value
    end

    add_index :ahoy_events, [:event_id, :name]
  end
end
