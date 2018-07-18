class CreateTests < ActiveRecord::Migration[4.2]
  def change
    create_table :test, id: false do |t|
      t.column :test_id, 'INTEGER PRIMARY KEY AUTOINCREMENT', null: false
      t.string :test, null: false
      t.string :test_before, null: false
      t.string :test_first_name, null: false
      t.string :test_last_name, null: false
      t.timestamps null: false
    end

  end
end
