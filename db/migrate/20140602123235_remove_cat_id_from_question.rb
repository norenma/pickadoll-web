class RemoveCatIdFromQuestion < ActiveRecord::Migration
  def change
  	remove_reference :question, :cat_id 
  end
end
