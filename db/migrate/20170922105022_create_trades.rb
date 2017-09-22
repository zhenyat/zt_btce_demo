class CreateTrades < ActiveRecord::Migration[5.1]
  def change
    create_table :trades do |t|
      t.references :pair, foreign_key: true
      t.integer :kind,   limit: 1
      t.decimal :price,  precision: 15, scale: 5
      t.decimal :amount, precision: 15, scale: 8
      t.integer :tid
      t.integer :timestamp

      t.timestamps
    end
  end
end
