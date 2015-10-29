class CreateQuestionnaires < ActiveRecord::Migration
  def change
    create_table :questionnaires do |t|
      t.string :name
      t.boolean :public
      t.text :description

      t.timestamps
    end
  end
end
