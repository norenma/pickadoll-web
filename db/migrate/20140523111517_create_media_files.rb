class CreateMediaFiles < ActiveRecord::Migration
  def change
    create_table :media_files do |t|
      t.string :ref
      t.string :media_type
      t.references :question, index: true

      t.timestamps
    end
  end
end
