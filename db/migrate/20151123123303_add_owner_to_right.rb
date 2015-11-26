class AddOwnerToRight < ActiveRecord::Migration
  def change
    add_reference :rights, :user, index: true
  end
end
