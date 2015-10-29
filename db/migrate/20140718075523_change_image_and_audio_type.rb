class ChangeImageAndAudioType < ActiveRecord::Migration
  def change
  	remove_column :categories, :image, :string 
  	remove_column :categories, :audio, :string 

  	add_column :categories, :image, :integer 
  	add_column :categories, :audio, :integer
  	
  end
end
