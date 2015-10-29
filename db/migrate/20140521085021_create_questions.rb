class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :name
      t.text :text
      t.text :settings
      t.integer :response_id
      t.boolean :is_public

      t.timestamps
    end
  end
end
