class AddNodesBinaryData < ActiveRecord::Migration
  def up
    add_column :nodes, :binary_data, :binary
    add_column :nodes, :binary, :boolean, :default => false
  end

  def down
    remove_column :nodes, :binary_data
    remove_column :nodes, :binary
  end
end
