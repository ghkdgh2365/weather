class CreateMises < ActiveRecord::Migration
  def change
    create_table :mises do |t|
      t.text :mise_info
      t.text :ozone_info

      t.timestamps null: false
    end
  end
end
