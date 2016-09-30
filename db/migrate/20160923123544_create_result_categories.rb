class CreateResultCategories < ActiveRecord::Migration
  def change
    create_table :result_categories do |t|
      t.string :name
      t.integer :order
      t.belongs_to :questionnaire, index: true
      t.timestamps
    end
  end
end
