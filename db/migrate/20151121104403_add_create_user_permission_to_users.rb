class AddCreateUserPermissionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :create_user_permission, :boolean
  end
end
