class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :path, :null => false
      t.text :data, :null => false
      t.boolean :directory
      t.datetime :updated_at, :null => false
      t.string :content_type, :null => false

      t.belongs_to :user, :null => false
    end

    add_index :nodes, :path

  end
end
