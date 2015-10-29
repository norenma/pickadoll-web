class CreateResponseOptions < ActiveRecord::Migration
  def change
    create_table :response_options do |t|
      t.string :name
      t.text :options

      t.timestamps
    end
  end
end
