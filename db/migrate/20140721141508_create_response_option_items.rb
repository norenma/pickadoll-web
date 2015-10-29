class CreateResponseOptionItems < ActiveRecord::Migration
  def change
    create_table :response_option_items do |t|
      t.integer :value
      t.text :label
      t.text :audio
      t.references :response_option, index: true

      t.timestamps
    end
  end
end
