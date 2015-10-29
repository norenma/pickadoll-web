class ChangeTypeOfTesterId < ActiveRecord::Migration
  def change
  	change_table :answers do |a|
  		a.change :tester_id, :string
  	end 
  end
end
