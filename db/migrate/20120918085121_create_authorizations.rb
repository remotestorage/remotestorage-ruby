class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.string :token, :null => false
      t.text :scope, :null => false
      t.string :origin, :null => false

      t.belongs_to :user, :null => false

      t.timestamps
    end

    add_index :authorizations, :token

  end
end
