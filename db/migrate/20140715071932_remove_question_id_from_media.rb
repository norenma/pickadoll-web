class RemoveQuestionIdFromMedia < ActiveRecord::Migration
  def change
  	add_column :questions, :question_image, :integer 
  	add_column :questions, :question_audio, :integer    
  end
end
