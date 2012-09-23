class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :name
      t.string :start_url
      t.string :icon_url
      t.string :website_url

      t.belongs_to :user

      t.timestamps
    end
  end
end
