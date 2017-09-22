class CreatePairs < ActiveRecord::Migration[5.1]
  def change
    create_table :pairs do |t|
      t.string  :name
      t.integer :decimal_places
      t.decimal :min_price,  precision: 10, scale: 5 
      t.integer :max_price
      t.decimal :min_amount, precision: 10, scale: 5
      t.integer :hidden,     limit: 1
      t.decimal :fee,        precision:  5, scale: 2

      t.timestamps
    end
  end
end
