class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    create_table :visitors, id: false do |t|
      t.uuid :id, primary_key: true

  end
end
