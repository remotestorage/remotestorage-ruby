class AllowNullForData < ActiveRecord::Migration
  def up
    change_column :nodes, :data, :text, :null => true
  end

  def down
  end
end
