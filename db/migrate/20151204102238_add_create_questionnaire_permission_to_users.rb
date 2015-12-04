class AddCreateQuestionnairePermissionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :create_questionnaire_permission, :boolean
  end
end
