class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :tester_id
      t.string :questionnaire
      t.string :question
      t.string :device_id
      t.string :answer_label
      t.string :answer_value
      t.string :answer_time
      t.string :user

      t.timestamps
    end
    add_index :answers, :questionnaire
    add_index :answers, :question
    add_index :answers, :user
  end
end
