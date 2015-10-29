class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.string :image
      t.text :description
      t.string :audio
      t.integer :order
      t.references :questionnaire, index: true

      t.timestamps
    end
  end
end
