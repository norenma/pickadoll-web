class RemoveCatIdFromQuestion < ActiveRecord::Migration
  def change
  	remove_reference :questions, :cat_id 
  end
end
