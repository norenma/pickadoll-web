class RemoveOptionsFromResponseOptions < ActiveRecord::Migration
  def change
  	remove_column :response_options, :options, :text 
  end
end
