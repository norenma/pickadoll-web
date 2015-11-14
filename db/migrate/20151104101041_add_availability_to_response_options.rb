class AddAvailabilityToResponseOptions < ActiveRecord::Migration
  def change
    add_column :response_options, :availability, :boolean
  end
end
