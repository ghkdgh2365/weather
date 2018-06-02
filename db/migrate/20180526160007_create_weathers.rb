class CreateWeathers < ActiveRecord::Migration
  def change
    create_table :weathers do |t|
      t.string :city
      t.string :region_name
      t.string :x_value
      t.string :y_value
      t.string :check_value
      t.text :w_time
      t.text :w_temp
      t.text :w_weather

      t.timestamps null: false
    end
  end
end
