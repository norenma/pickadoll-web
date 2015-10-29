class AddOwnerToQuestionnaire < ActiveRecord::Migration
  def change
  	add_reference :questionnaires, :user, index: true 
  end
end
